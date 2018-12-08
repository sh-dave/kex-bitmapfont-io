package kex.io;

import format.bmfont.types.*;
import format.bmfont.XmlReader;
import kex.io.AssetLog.*;

using tink.CoreApi;

class BitmapFontIO {
	var blobs: BlobIO;
	var cachedAssets: Map<String, BitmapFont> = new Map();
	var loadingAssets: Map<String, Array<FutureTrigger<Outcome<BitmapFont, Error>>>> = new Map();
	var urlToScope: Map<String, Array<String>> = new Map();

	public function new( blobs: BlobIO ) {
		this.blobs = blobs;
	}

	public function get( scope: String, path: String, file: String ) : Promise<BitmapFont> {
		var url = CoreIOUtils.tagAsset(urlToScope, scope, path, file);
		var cached = cachedAssets.get(url);
		var f = Future.trigger();

		asset_info('queue bitmapfont `$url` for scope `$scope`');

		if (cached != null) {
			asset_info('already cached bitmapfont `$url`, adding scope `$scope`');
			f.trigger(Success(cached));
			return f;
		}

		var loading = loadingAssets.get(url);

		if (loading != null) {
			asset_info('already loading bitmapfont `$url`, adding scope `$scope`');
			loading.push(f);
			return f;
		}

		asset_info('loading bitmapfont `$url` for scope `$scope`');
		loadingAssets.set(url, [f]);

		return blobs.get(scope, path, file)
			.next(function( blob ) {
				try {
					var font = XmlReader.read(Xml.parse(blob.toString()));

					cachedAssets.set(url, font);
					var r = Success(font);

					for (t in loadingAssets.get(url)) {
						t.trigger(r);
					}

					loadingAssets.remove(url);
					return r;
				} catch (x: Dynamic) {
					var r = Failure(new Error(Std.string(x)));

					for (t in loadingAssets.get(url)) {
						t.trigger(r);
					}

					loadingAssets.remove(url);
					return r;
				}
			});
	}

	public function unloadScope( scope: String ) {
		for (url in urlToScope.keys()) {
			var scopes = urlToScope.get(url);

			if (scopes.indexOf(scope) != -1) {
				unload(scope, url);
			}
		}
	}

	function unload( scope: String, url: String ) {
		var scopes = urlToScope.get(url);

		asset_info('unscoping bitmapfont `$url` for `$scope`');
		scopes.remove(scope);

		if (scopes.length == 0) {
			asset_info('unloading bitmapfont `$url`');
			cachedAssets.remove(url);
			blobs.unloadBlob(scope, url);
		}
	}
}
