const path = require('path')
const Dotenv = require('dotenv-webpack');
require('dotenv').config();
const StringReplacePlugin = require('string-replace-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

module.exports = function(env) {
  let dotenv =  new Dotenv();

  return {
    entry: './js/app.js',
    mode: 'development',
    output: {
      path: path.resolve(__dirname),
      filename: 'dist/bundle.js'
    },
    module: {
      rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: 
          [
            StringReplacePlugin.replace({
              replacements: [
                { pattern: /\%API_URL\%/g, replacement: () => process.env.API_URL },
                { pattern: /\%API_VERSION\%/g, replacement: () => process.env.API_VERSION },
                { pattern: /\%GOOGLE_API_KEY\%/g, replacement: () => process.env.GOOGLE_API_KEY },
                { pattern: /\%SOCKETIO_URL\%/g, replacement: () => process.env.SOCKETIO_URL },
              ]
            }),
            {
              loader: 'elm-webpack-loader',
              options: {
                  debug: env ? env.development : false, 
                  warn: env ? env.development : false
              }
            }
        ]
      }, {
        test: /\.css$/,
        use: ["style-loader", "css-loader"]
      }, {
        test: /\.scss$/,
        use: ["style-loader", "css-loader", "sass-loader"]
      },
      { test: /\.(ttf|eot|svg|woff|woff2)(\?v=[0-9]\.[0-9]\.[0-9])?$/, 
        loader: "file-loader",
        options: {
            //emitFile: true,
            name: '[name].[ext]',
            outputPath: 'fonts/'
        }
      },
      {
        test: /\.html$/,
        use: [
          { loader: 'babel-loader' },
        ]
      }
    ]
    },
    plugins: [
      dotenv,
      new StringReplacePlugin(),
      new UglifyJsPlugin({
        test: /\.js($|\?)/i,
        parallel: true,
        cache: true
      })
    ]
  }
}

