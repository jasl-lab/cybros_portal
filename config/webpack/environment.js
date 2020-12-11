const { environment } = require('@rails/webpacker')

const datatables = require('./loaders/datatables')
environment.loaders.append('datatables', datatables)

const webpack = require('webpack');

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
  })
)

module.exports = environment
