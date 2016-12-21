let webpack = require("webpack"),
    path = require("path");

module.exports = {
  entry: "./app/js/app.js",
  output: {
    path: path.resolve("public/assets"),
    publicPath: "/biscotti/assets/",
    filename: "js/app.js"
  },
  module: {
    loaders: [
      { test: /\.html$/, loader: "file?name=[name].[ext]"},
      { test: /\.css$/, loader: "style!css" },
      { test: /\.scss$/, loaders: ["style-loader", "css-loader", "sass-loader"]},
      { test: /\.js$/, loader: "babel-loader" },
      { test: /\.(ttf|eot|svg|woff2?)(\?v=[a-z0-9=\.]+)?$/i, loader: "file?name=fonts/[name].[ext]" }
    ]
  },
  plugins: [],
};
