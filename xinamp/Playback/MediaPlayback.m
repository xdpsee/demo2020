//
//  MediaPlayback.m
//  xinamp
//
//  Created by chen zhenhui on 2020/5/3.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import "MediaPlayback.h"
#import <gst/gst.h>

GST_DEBUG_CATEGORY_STATIC (debug_category);
#define GST_CAT_DEFAULT debug_category

#define SEEK_MIN_DELAY (500 * GST_MSECOND)

@interface MediaPlayback ()

- (void) process;

@end

@implementation MediaPlayback {
    GstElement* playbin;
    GstElement* equalizer;
    GstElement* converter;
    GstElement* audiosink;
    
    GMainContext* context;
    GMainLoop* main_loop;
    
    id<MediaPlaybackDelegate> _delegate;
    
    gboolean _loop;
    const char* _uri;
    GstState state;
    GstState target_state;
    gint64 duration;             /* Cached clip duration */
    gint64 desired_position;     /* Position to seek to, once the pipeline is running */
    GstClockTime last_seek_time; /* For seeking overflow prevention (throttling) */
    gboolean is_live;            /* Live streams do not use buffering */
    
    
    volatile gboolean initialized;
    volatile gboolean exited;
    NSCondition* initCond;
}

@synthesize delegate = _delegate;
@synthesize uri = _uri;
@synthesize loop = _loop;

static void g_object_safe_unref(gpointer object) { if (object) g_object_unref(object);}

- (id) initWithUri:(const char*) uri delegate:(id<MediaPlaybackDelegate>)delegate start:(BOOL) start
{
    g_print("MediaPlayback init\n");
    
    self = [super init];
    if (self) {
        self->_delegate = delegate;
        self->_uri = uri;
        self->target_state = start ? GST_STATE_PLAYING : GST_STATE_READY;
        self->duration = GST_CLOCK_TIME_NONE;
        self->last_seek_time = GST_CLOCK_TIME_NONE;
        self->initCond = [[NSCondition alloc] init];
        
        GST_DEBUG_CATEGORY_INIT (debug_category, "Xinamp", 0, "Xinamp Player");
        gst_debug_set_threshold_for_name("Xinamp", GST_LEVEL_DEBUG);
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self process];
        });
        
        [initCond lock];
        g_print("initCond start wait\n");
        [initCond wait];
        g_print("initCond end wait\n");
        [initCond unlock];
    }
    
    return self;
}

- (void) dealloc {
    self->_delegate = nil;
    self->_uri = nil;
    self->initCond = nil;
    
    g_print("MediaPlayback dealloc\n");
}

- (void) stop {
    BOOL quiting = FALSE;
    while (TRUE) {
        g_print("MediaPlayback stop...\n");
        if (exited) {
            break;
        }
        
        @synchronized (self) {
            if (initialized && main_loop && !quiting) {
                if (g_main_loop_is_running(main_loop)) {
                    gst_element_set_state(playbin, GST_STATE_NULL);
                    g_main_loop_quit(main_loop);
                    quiting = TRUE;
                }
            }
        }
    }
    
    g_print("MediaPlayback stopped.\n");
}

- (void) play {
    target_state = GST_STATE_PLAYING;
    is_live = (gst_element_set_state (playbin, GST_STATE_PLAYING) == GST_STATE_CHANGE_NO_PREROLL);
}

- (void) pause {
    target_state = GST_STATE_PAUSED;
    is_live = (gst_element_set_state (playbin, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
}

-(void) setPosition:(NSInteger)milliseconds
{
    gint64 position = (gint64)(milliseconds * GST_MSECOND);
    if (state >= GST_STATE_PAUSED) {
        execute_seek(position, self);
    } else {
        g_print("Scheduling seek to %" GST_TIME_FORMAT " for later\n", GST_TIME_ARGS (position));
        self->desired_position = position;
    }
}

- (void) process {
    
    g_print("Creating pipeline\n");

    playbin = gst_element_factory_make("playbin3", "pipeline");
    converter = gst_element_factory_make ("audioconvert", "convert");
    equalizer = gst_element_factory_make ("equalizer-10bands", "equalizer");
    audiosink = gst_element_factory_make ("osxaudiosink", "audio_sink");
    if (!playbin || !converter || !equalizer || !audiosink) {
        g_printerr("Not all elements could be created.\n");
        g_object_safe_unref(playbin);
        g_object_safe_unref(converter);
        g_object_safe_unref(equalizer);
        g_object_safe_unref(audiosink);
        [initCond lock];
        exited = TRUE;
        g_print("initCond signal, exited = TRUE\n");
        [initCond signal];
        [initCond unlock];
        return;
    }
    
    /* Create our own GLib Main Context and make it the default one */
    context = g_main_context_new();
    g_main_context_push_thread_default(context);
    
    /* Create the sink bin, add the elements and link them */
    GstElement* bin = gst_bin_new ("audio_sink_bin");
    gst_bin_add_many (GST_BIN (bin), converter, equalizer, audiosink, NULL);
    gst_element_link_many(converter, equalizer, audiosink, NULL);
    GstPad* pad = gst_element_get_static_pad (converter, "sink");
    GstPad* ghost_pad = gst_ghost_pad_new ("sink", pad);
    gst_pad_set_active (ghost_pad, TRUE);
    gst_element_add_pad (bin, ghost_pad);
    gst_object_unref (pad);
    
    /* Configure the equalizer */
    g_object_set (G_OBJECT (equalizer), "band1", (gdouble)-24.0, NULL);
    g_object_set (G_OBJECT (equalizer), "band2", (gdouble)-24.0, NULL);

    /* Set playbin's audio sink to be our sink bin */
    g_object_set (GST_OBJECT (playbin), "audio-sink", bin, NULL);
    g_object_set(playbin, "uri", _uri, NULL);
    //g_object_set(playbin, "ring-buffer-max-size", (guint64) 1024 * 16, NULL);
    
    GstBus* bus = gst_element_get_bus(playbin);
    GSource* bus_source = gst_bus_create_watch(bus);
    g_source_set_callback (bus_source, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
    g_source_attach (bus_source, context);
    g_source_unref (bus_source);
    g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (__bridge void *)self);
    g_signal_connect (G_OBJECT (bus), "message::eos", (GCallback)eos_cb, (__bridge void *)self);
    g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)state_changed_cb, (__bridge void *)self);
    g_signal_connect (G_OBJECT (bus), "message::duration", (GCallback)duration_cb, (__bridge void *)self);
    g_signal_connect (G_OBJECT (bus), "message::buffering", (GCallback)buffering_cb, (__bridge void *)self);
    g_signal_connect (G_OBJECT (bus), "message::clock-lost", (GCallback)clock_lost_cb, (__bridge void *)self);
    gst_object_unref (bus);
    
    /* Register a function that GLib will call 4 times per second */
    GSource* timeout_source = g_timeout_source_new (1000);
    g_source_set_callback (timeout_source, (GSourceFunc)refresh_ui, (__bridge void *)self, NULL);
    g_source_attach (timeout_source, context);
    g_source_unref (timeout_source);
    
    gst_element_set_state(playbin, self->target_state);
    main_loop = g_main_loop_new (context, FALSE);
    
    [initCond lock];
    initialized = TRUE;
    g_print("initCond signal, initialized = TRUE\n");
    [initCond signal];
    [initCond unlock];
    
    g_print("Enter main loop...\n");
    g_main_loop_run(main_loop);
    g_print("Exited main loop...\n");
    
    g_main_context_pop_thread_default(context);
    g_main_context_unref (context);
    
    @synchronized (self) {
        gst_element_set_state (playbin, GST_STATE_NULL);
        g_main_loop_unref (main_loop);
        main_loop = NULL;
    }
    
    gst_object_unref(playbin);
    
    exited = TRUE;
    g_print("Exited pipeline\n");
}

#pragma mark -- Pipeline callback
static void state_changed_cb (GstBus *bus, GstMessage *msg, MediaPlayback *self)
{
    GstState old_state, new_state, pending_state;
    gst_message_parse_state_changed (msg, &old_state, &new_state, &pending_state);
    if (GST_MESSAGE_SRC (msg) == GST_OBJECT (self->playbin)) {
        self->state = new_state;
        gchar *message = g_strdup_printf("State changed to %s", gst_element_state_get_name(new_state));
        g_print("%s\n", message);
        
        g_free (message);
    }
}

/* Retrieve errors from the bus and show them on the UI */
static void error_cb (GstBus *bus, GstMessage *msg, MediaPlayback *self)
{
    GError *err;
    gchar *debug_info;
    gchar *message_string;

    gst_message_parse_error (msg, &err, &debug_info);
    message_string = g_strdup_printf ("Error received from element %s: %s", GST_OBJECT_NAME (msg->src), err->message);
    g_clear_error (&err);
    g_free (debug_info);
    
    g_print("%s\n", message_string);
    
    g_free (message_string);
    
    g_main_loop_quit(self->main_loop);
}

static void eos_cb (GstBus *bus, GstMessage *msg, MediaPlayback *self)
{
//    self->target_state = GST_STATE_PAUSED;
//    self->is_live = (gst_element_set_state (self->playbin, GST_STATE_PAUSED) == GST_STATE_CHANGE_NO_PREROLL);
//    execute_seek (0, self);
    
    if (self->_loop) {
        g_print("End of stream, but loop = TRUE\n");
        execute_seek (0, self);
    } else {
        g_print("End of stream, quit main loop...\n");
        g_main_loop_quit(self->main_loop);
        
        if ([self->_delegate respondsToSelector:@selector(playbackCompleted:)]) {
            [self->_delegate playbackCompleted:self->_uri];
        }
    }
}

/* Called when the duration of the media changes. Just mark it as unknown, so we re-query it in the next UI refresh. */
static void duration_cb (GstBus *bus, GstMessage *msg, MediaPlayback *self) {
    self->duration = GST_CLOCK_TIME_NONE;
}

/* Called when buffering messages are received. We inform the UI about the current buffering level and
 * keep the pipeline paused until 100% buffering is reached. At that point, set the desired state. */
static void buffering_cb (GstBus *bus, GstMessage *msg, MediaPlayback *self) {
    gint percent;

    if (self->is_live)
        return;
    
    gst_message_parse_buffering (msg, &percent);
    if (percent < 100 && self->target_state >= GST_STATE_PAUSED) {
        gchar * message_string = g_strdup_printf ("Buffering %d%%", percent);
        gst_element_set_state (self->playbin, GST_STATE_PAUSED);
        g_print("%s\n", message_string);
        g_free (message_string);
    } else if (self->target_state >= GST_STATE_PLAYING) {
        gst_element_set_state (self->playbin, GST_STATE_PLAYING);
    } else if (self->target_state >= GST_STATE_PAUSED) {
        g_print("Buffering complete\n");
    }
}

/* Called when the clock is lost */
static void clock_lost_cb (GstBus *bus, GstMessage *msg, MediaPlayback *self) {
    if (self->target_state >= GST_STATE_PLAYING) {
        gst_element_set_state (self->playbin, GST_STATE_PAUSED);
        gst_element_set_state (self->playbin, GST_STATE_PLAYING);
    }
}

static void execute_seek (gint64 position, MediaPlayback *self) {
    gint64 diff;

    if (position == GST_CLOCK_TIME_NONE)
        return;

    diff = gst_util_get_timestamp () - self->last_seek_time;

    if (GST_CLOCK_TIME_IS_VALID (self->last_seek_time) && diff < SEEK_MIN_DELAY) {
        /* The previous seek was too close, delay this one */
        GSource *timeout_source;

        if (self->desired_position == GST_CLOCK_TIME_NONE) {
            /* There was no previous seek scheduled. Setup a timer for some time in the future */
            timeout_source = g_timeout_source_new ((guint)(SEEK_MIN_DELAY - diff) / GST_MSECOND);
            g_source_set_callback (timeout_source, (GSourceFunc)delayed_seek_cb, (__bridge void *)self, NULL);
            g_source_attach (timeout_source, self->context);
            g_source_unref (timeout_source);
        }
        /* Update the desired seek position. If multiple requests are received before it is time
         * to perform a seek, only the last one is remembered. */
        self->desired_position = position;
        GST_DEBUG ("Throttling seek to %" GST_TIME_FORMAT ", will be in %" GST_TIME_FORMAT,
                   GST_TIME_ARGS (position), GST_TIME_ARGS (SEEK_MIN_DELAY - diff));
    } else {
        /* Perform the seek now */
        GST_DEBUG ("Seeking to %" GST_TIME_FORMAT, GST_TIME_ARGS (position));
        self->last_seek_time = gst_util_get_timestamp ();
        gst_element_seek_simple (self->playbin, GST_FORMAT_TIME, GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_KEY_UNIT, position);
        self->desired_position = GST_CLOCK_TIME_NONE;
    }
}

/* Delayed seek callback. This gets called by the timer setup in the above function. */
static gboolean delayed_seek_cb (MediaPlayback *self)
{
    GST_DEBUG("Doing delayed seek to %" GST_TIME_FORMAT, GST_TIME_ARGS (self->desired_position));
    execute_seek (self->desired_position, self);
    return FALSE;
}

static gboolean refresh_ui (MediaPlayback *self) {
    gint64 position;

    if (!self || !self->playbin || self->state < GST_STATE_PAUSED) {
        return TRUE;
    }
    
    if (!GST_CLOCK_TIME_IS_VALID (self->duration)) {
        gst_element_query_duration (self->playbin, GST_FORMAT_TIME, &self->duration);
    }

    if (gst_element_query_position (self->playbin, GST_FORMAT_TIME, &position)) {
        gchar status[64] = {0,};
        memset (status, ' ', sizeof(status) - 1);
        if (position != -1 && self->duration > 0 && self->duration != -1) {
            gchar dstr[32], pstr[32];

            g_snprintf(pstr, 32, "%" GST_TIME_FORMAT, GST_TIME_ARGS (position));
            pstr[9] = '\0';
            g_snprintf(dstr, 32, "%" GST_TIME_FORMAT, GST_TIME_ARGS (self->duration));
            dstr[9] = '\0';
            //g_print("%s / %s %s\n", pstr, dstr, status);
        }
    }
    
    return TRUE;
}

@end



