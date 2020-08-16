var Encore = require('@symfony/webpack-encore');

Encore
    .setOutputPath('public/build/')
    .setPublicPath('/build')

    // JS Libraries
    .addEntry('app', [
        './assets/js/main.js',
    ])
    // Stylesheets
    .addStyleEntry('global', [
        './assets/css/main.styl',
        './node_modules/bootstrap/dist/css/bootstrap.min.css',
        './node_modules/bootstrap-datepicker/dist/css/bootstrap-datepicker3.css',
        './node_modules/font-awesome/css/font-awesome.min.css'
    ])
    // Static files (images, etc)
    .copyFiles({
        from: './assets/images'
    })
    // Misc encore webpack features
    .enableStylusLoader()
    .cleanupOutputBeforeBuild()
    .enableSourceMaps(!Encore.isProduction())
    .enableSingleRuntimeChunk()
    .configureWatchOptions(function (watchOptions) {
        watchOptions.poll = 250; // Use polling on nfs-mount vm.
    })
;

module.exports = Encore.getWebpackConfig();
