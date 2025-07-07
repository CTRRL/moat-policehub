fx_version "cerulean"

description "Epic store made Police Hub. Developer: moat"
author "Project Error"
version '2.0'

lua54 'yes'

games {
  "gta5"
}

escrow_ignore {
  "client/**/*"
}

ui_page 'web/build/index.html'

client_script "client/**/*"
server_script "server/**/*"

files {
  'web/build/index.html',
  'web/build/**/*'
}
