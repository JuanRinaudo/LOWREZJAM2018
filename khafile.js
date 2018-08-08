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

//project.addParameter('-dce std');

if (platform === 'debug-html5' || platform === 'html5') {
	project.addAssets('Assets/Data/web/**');
	project.addAssets('Assets/Web/**');
}

if (platform === 'android') {
	project.addAssets('Assets/Data/android/**');
}

//Data for hotloading
if (platform === 'debug-html5' || platform === 'krom') {
	project.addAssets('Data/game/**');
}

resolve(project);