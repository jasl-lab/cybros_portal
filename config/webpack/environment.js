const { environment } = require('@rails/webpacker')

const datatables = require('./loaders/datatables')
environment.loaders.append('datatables', datatables)

module.exports = environment
