# Базовый модуль для Gulp
gulp = require "gulp"

# Модули для сборки стилей
sass = require "gulp-sass"
cleanCSS = require "gulp-clean-css"
autoprefixer = require "gulp-autoprefixer"

# Модули для сборки скриптов
coffee = require "gulp-coffee"
uglify = require "gulp-uglify"
concat = require "gulp-concat"

# Вспомогательные модули
gulpif = require "gulp-if"
changed = require "gulp-changed"
sourcemaps = require "gulp-sourcemaps"
fileInclude = require "gulp-file-include"
browserSync = require "browser-sync"

# Модули для обработки изображений
svgmin = require "gulp-svgmin"
svgSprite = require "gulp-svg-sprites"

# Пути к ресурсам
path =
  scripts:
    build: "build/js"
    dest: "src/js"
    source: []
  styles:
    build: "build/css"
    dest: "src/css"
    all: "src/sass/**/*.sass"
    source: "src/sass/*.sass"
  icons:
    dest: "src/images"
    source: "src/images/icons/*.svg"
  images:
    build: "build/images"
    source: [
      "src/images/**/*.jpg"
      "src/images/**/*.png"
    ]
  html:
    source: "src/*.html"
    build: "build"
    dest: "src"

# Опции плагинов
options =
  autoprefixer:
    browsers: ["last 2 versions"]
    cascade: false
  svgSprite:
    svgId: "icon-%f"
    mode: "symbols"
    preview: false
    svg:symbols: "icons.svg"
  fileInclude:
    prefix: "@@"
    basepath: "src"
  browserSync:
    server: baseDir: "src"

# Режим сборки: false - режим разработки, true - сборка в продакшн
buildMode = false

# Task: [CSS] Компилируем и собираем стили
# Note: Для продакшена и для разработки генерируется разный CSS
gulp.task "css", ->
  gulp.src path.styles.source
  .pipe changed path.styles.dest, extension: ".css"
  .pipe gulpif !buildMode, sourcemaps.init()
  .pipe sass()
  .pipe gulpif !buildMode, sourcemaps.write()
  .pipe gulpif buildMode, autoprefixer options.autoprefixer
  .pipe gulpif buildMode, cleanCSS()
  .pipe gulpif !buildMode, gulp.dest path.styles.dest
  .pipe gulpif buildMode, gulp.dest path.styles.build
  .pipe gulpif !buildMode, browserSync.stream()

# Task: [Icons] Собираем спрайт из SVG иконок
gulp.task "icons", ->
  gulp.src path.icons.source
  .pipe svgmin()
  .pipe svgSprite options.svgSprite
  .pipe gulp.dest path.icons.dest

# Task: [JS] Компилируем и собираем скрипты
# Note: Для продакшена и для разработки генерируется разный JS
gulp.task "js", ->
  gulp.src path.scripts.source
  .pipe gulpif !buildMode, sourcemaps.init()
  .pipe coffee()
  .pipe concat("main.js")
  .pipe gulpif !buildMode, sourcemaps.write()
  .pipe gulpif buildMode, uglify()
  .pipe gulpif !buildMode, gulp.dest path.scripts.dest
  .pipe gulpif buildMode, gulp.dest path.scripts.build

# Task: [Images] Оптимизируем изображения и отправляем их в продакшн
# Note: Таск используется только для продакшена
gulp.task "images", ->
  gulp.src path.images.source
  .pipe changed path.images.build
  .pipe gulp.dest path.image.build

# Task: [HTML] Включаем в HTML инлайн стили для оптимизации
gulp.task "html", ->
  gulp.src path.html.source
  .pipe fileInclude options.fileInclude
  .pipe gulpif buildMode, gulp.dest path.html.build
  .pipe gulpif !buildMode, browserSync.stream()

# Task: [BrowserSync] Инициализируем сервер для разработки
gulp.task "browser-sync", ->
  browserSync options.browserSync

# Task: [Watch] Режим сборки для разработки
gulp.task "watch", ["browser-sync", "html"] ->
  gulp.watch path.styles.all, ["css"]
  gulp.watch path.scripts.source, ["js"], browserSync.reload
  gulp.watch path.html.source, ["html"]

gulp.task "default", ["watch"]
