let project = new Project('Fart');

project.addLibrary('zui');
project.addLibrary('kext');
project.addLibrary('tweenxcore');

project.addShaders('Assets/Shaders/**');

project.addAssets('Assets/Common/**');
project.addAssets('Assets/Images/**');
project.addAssets('Assets/Atlas/**');
project.addAssets('Assets/Sound/**');
project.addAssets('Assets/Data/**');

project.addSources('Source');

if (platform === 'html5') {
	project.addAssets('Assets/Web/**');
}

if (platform === 'android') {
	project.addAssets('Assets/Data/android/**');
}

//Data for hotloading
project.addAssets('Data/game/**');

resolve(project);