let project = new Project('kex-bitmapfont-io');
project.addLibrary('haxe-format-bmfont');
project.addLibrary('kex-io');
project.addSources('src');
resolve(project);
