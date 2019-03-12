package kex.io;

import format.bmfont.types.BitmapFont;
import format.bmfont.XmlReader;

using tink.CoreApi;

// TODO (DK) load pages as well?
class BitmapFontIO extends GenericIO<BitmapFont> {
	var blobs: BlobIO;

	public function new( blobs: BlobIO ) {
		super('bitmapfont');
		this.blobs = blobs;
	}

	override function onResolve( scope: String, path: String, file: String ) : Promise<BitmapFont> {
		return blobs.get(scope, path, file)
			.next(function( blob ) return XmlReader.read(Xml.parse(blob.toString())));
	}
}
