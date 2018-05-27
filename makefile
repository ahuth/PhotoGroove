deps:
	elm-package install

compile:
	elm-make PhotoGroove.elm --output elm.js
