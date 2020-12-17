const { environment } = require('@rails/webpacker')

const datatables = require('./loaders/datatables')
environment.loaders.append('datatables', datatables)

const webpack = require('webpack');

const MomentLocalesPlugin = require('moment-locales-webpack-plugin');

environment.plugins.append(
  'Provide',
  new MomentLocalesPlugin({
    localesToKeep: ['zh-CN'],
  }),
)

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
  })
)

module.exports = environment
