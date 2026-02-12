#!/usr/bin/env bash

IMG="org.geeqie.Geeqie.desktop"
MPV="mpv.desktop"
TXT="nvim.txteditor.desktop"

for mime in \
	image/png \
	image/jpeg \
	image/webp \
	image/heic \
	image/avif \
	image/jxl; do
	xdg-mime default "$IMG" "$mime"
done

for mime in \
	video/mp4 \
	video/x-matroska \
	video/webm \
	video/quicktime \
	audio/mpeg \
	audio/flac \
	audio/ogg \
	audio/wav; do
	xdg-mime default "$MPV" "$mime"
done

xdg-mime default "$TXT" text/plain
