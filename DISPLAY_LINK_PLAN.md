# SDL Display Link API Plan

## Summary

Introduce a first-class SDL display link API modeled on `wio-extra`'s
`Window.createDisplayLink`: an opaque handle created from an `SDL_Window`,
explicit `start`/`stop`/`destroy` lifecycle calls, and an SDL event carrying
display-timed frame data.

The initial implementation targets Cocoa/macOS. Other video backends fail
cleanly through the generic API with `SDL_Unsupported()`.

## Public API

Add to `include/SDL3/SDL_video.h`:

- `SDL_DisplayLink`, an opaque display link handle.
- `SDL_DisplayLinkID`, a unique ID for event correlation.
- `SDL_DisplayLinkOptions`, with `preferred_frame_rate_hz`; `0.0` means the
  platform default.
- `SDL_CreateDisplayLink(SDL_Window *window, const SDL_DisplayLinkOptions *options)`.
- `SDL_StartDisplayLink(SDL_DisplayLink *display_link)`.
- `SDL_StopDisplayLink(SDL_DisplayLink *display_link)`.
- `SDL_DestroyDisplayLink(SDL_DisplayLink *display_link)`.
- `SDL_GetDisplayLinkID(SDL_DisplayLink *display_link)`.
- `SDL_GetDisplayLinkWindow(SDL_DisplayLink *display_link)`.

Add to `include/SDL3/SDL_events.h`:

- `SDL_EVENT_DISPLAY_LINK`.
- `SDL_DisplayLinkEvent`, available as `event.display_link`.
- Event fields: SDL queue timestamp, `windowID`, `displayLinkID`,
  `frame_timestamp_s`, and `duration_s`.

`frame_timestamp_s` and `duration_s` mirror `wio-extra`'s
`DisplayLinkFrame`. They are native display-link timing values in seconds,
separate from SDL's nanosecond event queue timestamp.

## Implementation

- SDL owns the `SDL_DisplayLink` object, validates it like other SDL handles,
  and links it from the owning `SDL_Window`.
- `SDL_DestroyWindow()` destroys all display links owned by the window before
  platform window teardown.
- The video driver interface has hooks to create, start, stop, and destroy the
  native display link.
- `SDL_SendDisplayLinkEvent()` pushes `SDL_EVENT_DISPLAY_LINK` and coalesces
  older queued display-link events with the same `displayLinkID`, matching the
  "latest frame wins" behavior used by `wio-extra`.
- Cocoa uses AppKit `CADisplayLink` from the window content view, starts it
  paused, resets timing on start/stop, applies `preferred_frame_rate_hz` when
  non-zero, and invalidates it during destroy.
- Dynapi tables are regenerated so the new public functions are exported.

## Caveats

- v1 is macOS/Cocoa only.
- The Cocoa implementation requires macOS runtime support for
  `NSView displayLinkWithTarget:selector:` and returns an SDL error when not
  available.
- Display links are timing sources only. They do not present, swap buffers,
  replace renderer vsync, or make any graphics context current.
- If the app falls behind, SDL intentionally coalesces queued display link
  events instead of preserving every native callback.
- Multiple display links per window are allowed, but most applications should
  create one per window.

## Test Plan

- Build SDL on macOS with CMake.
- Create a small window, call `SDL_CreateDisplayLink()`, start it, wait for
  `SDL_EVENT_DISPLAY_LINK`, and verify `windowID`, `displayLinkID`, and timing
  fields.
- Stop and destroy the display link, then verify no more display link events
  are received.
- Destroy a window while a display link is live and verify teardown is clean.
- Run against a non-Cocoa backend and verify creation returns `NULL` with an
  unsupported error.
