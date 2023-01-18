const path = require('path');
const PATHS = { src: path.join(__dirname, 'src')  };
const webpack = require('webpack');
const ESLintPlugin = require('eslint-webpack-plugin');

console.log(JSON.stringify(PATHS));



// Define main entry point for webpack.config.js here
const mainEntryPoint = './webroot/js/app.js';
const mainBundleName = 'jsbundle';

// Define entryObject with first main-entrypoint. 
// This entryObject will be used for webpack-entry. 
const webConfigEntries = {};
webConfigEntries[mainBundleName] = mainEntryPoint;



console.log( JSON.stringify( webConfigEntries ) + ' created!');

module.exports = (env, argv) => ({

    watch: argv.mode === 'production' ? false : true,

    module: {
        rules: [

            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel-loader',
            },
           
        ]
    },

    // https://webpack.js.org/concepts/entry-points/#multi-page-application
    entry: webConfigEntries,

    output: {
        path: path.resolve(__dirname, "./webroot/js/distro"),
        filename: "[name].js"
    },


    //watch: argv.mode === 'production' ? false : true,
    stats:{ children: true},
    mode: argv.mode === 'production' ? 'production' : 'development',
    
    //If webpack.SourceMapDevToolPlugin is used, set devtool: false; or it won't work!!!
    // In Production.Mode webpack.SourceMapDevToolPlugin will overstuff files, because minimizers are
    // switched off. Use in producion mode 'source-map' to turn 'off' SourceMapDevToolPluginas
    // devtool: false will activate SourceMapDevToolPlugin configs to be loaded
    
    devtool: false,

    optimization: {
        splitChunks: {
            // include all types of chunks
            name: 'vendors',
            chunks: 'all'
        }
    },

    
  
    // https://webpack.js.org/concepts/plugins/
    plugins: [
    
        // Provide variables to root html doc
        new webpack.ProvidePlugin({
            $: 'jquery',
            jQuery: 'jquery',
            }),

        new ESLintPlugin({}),

        // Create Cache-Safe SourceMaps (with Hash) in Dev-Mode, but don't create any in Prod-Mode 
        new webpack.SourceMapDevToolPlugin(
                    {
                filename: '[file].map',
                append: '\n//# sourceMappingURL=[file].map?hash=[chunkhash]',
                //EXCLUDE EVERYTHING in Producion Mode
                exclude: argv.mode === 'production' ? /(.*)/ : /(?!)/,
                module: true,
                columns: true,
                // lineToLine: false,
                noSources: argv.mode === 'production' ? true : false,
                namespace: ''    
                } 
            
        )

    
    ],

 
});