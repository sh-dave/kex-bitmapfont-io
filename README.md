# kex-bitmapfont-io

Wrapper around [haxe-format-bmfont](https://github.com/sh-dave/haxe-format-bmfont) and [kex-io](https://github.com/sh-dave/kex-io) to simplify font loading. See [kex-io's readme](https://github.com/sh-dave/kex-io/blob/master/README.md) for slighly more detailed documentation.

# usage

```haxe
using tink.CoreApi;

function foo() {
	var blobs = new kex.io.BlobIO();
	var bmfonts = new kex.io.BitmapFontIO(blobs);

	// load some fonts into different scopes
	Promise.inSequence([
		bmfonts.get('debugmenu', './fonts', 'arial.ttf'),
		bmfonts.get('debugmenu', './fonts', 'verdana.ttf'),
		bmfonts.get('game', './fonts', 'verdana.ttf'),
		bmfonts.get('game', './fonts', 'tahoma.ttf'),
	]).handle(function( o ) switch o {
		case Success(fnts):
			trace('fonts loaded');
		case Failure(err):
			trace('fonts failed to load: ${err}');
	});

	// unload the `debug-menu` scope
	bmfonts.unloadScope('debug-menu');

	// arial is unloaded, verdana and tahoma are still available
}
```
