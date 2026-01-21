#ifdef DEBUG
#define TRACE(fmt, args...) NSLog(@fmt, ## args)
#define fTRACE(fmt, args...) NSLog(@"%s: " fmt, __func__, ## args)
#else
#define TRACE(fmt, args...)
#define fTRACE(fmt, args...)
#endif

#define TRACE_HERE TRACE("%s\n", __func__)

#define DEBUG_RECT(string, rect) \
TRACE("%s rect: x: %f, y: %f, w: %f, h: %f\n", string, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

#define DEBUG_SIZE(string, size) \
TRACE("%s size: w: %f, h: %f\n", string, size.width, size.height)

#define DEBUG_POINT(string, origin) \
TRACE("%s point: x: %f, y: %f\n", string, origin.x, origin.y)

#define DEBUG_RC(string, pointer) \
TRACE("%s %p=%d\n", string, pointer, [pointer retainCount])

#define MAKE_CENTER_FRAME(f, w) \
CGRectMake(w.size.width/2.0-f.size.width/2.0, \
w.size.height/2.0-f.size.height/2.0, \
f.size.width, f.size.height)
