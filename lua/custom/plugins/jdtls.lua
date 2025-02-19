-- thanks ChatGpt
return {
  'mfussenegger/nvim-jdtls',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
  ft = { 'java' },
  config = function()
    local mason_pkg = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
    local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

    -- Force Java 21 from SDKMAN
    local jdk_path = vim.fn.glob '~/.sdkman/candidates/java/21.*/bin/java'
    if vim.loop.fs_stat(jdk_path) == nil then
      vim.notify('⚠️ JDK 21 not found in SDKMAN! Falling back to system Java.', vim.log.levels.WARN)
      jdk_path = vim.fn.exepath 'java' -- Use system Java as fallback
    else
      vim.notify('✅ Using JDK: ' .. jdk_path, vim.log.levels.DEBUG)
    end

    -- Find the correct JDTLS JAR file
    local equinox_launcher = vim.fn.glob(mason_pkg .. '/plugins/org.eclipse.equinox.launcher_*.jar')
    if equinox_launcher == '' then
      vim.notify('❌ JDTLS launcher JAR not found! Install JDK 21 with SDKMAN', vim.log.levels.ERROR)
      return
    end

    -- Determine OS for config_linux/mac
    local system_os = vim.loop.os_uname().sysname
    local config_os = (system_os == 'Darwin') and 'config_mac' or 'config_linux'

    -- Explicitly set JAVA_HOME to SDKMAN's JDK 21
    local env = vim.tbl_extend('force', vim.fn.environ(), {
      JAVA_HOME = vim.fn.fnamemodify(jdk_path, ':h:h'),
    })

    local config = {
      cmd = {
        jdk_path, -- Java 21 executable
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        equinox_launcher,
        '-configuration',
        mason_pkg .. '/' .. config_os,
        '-data',
        workspace_dir,
      },
      root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },
      env = env, -- Set JAVA_HOME for JDTLS
    }

    require('jdtls').start_or_attach(config)
  end,
}
