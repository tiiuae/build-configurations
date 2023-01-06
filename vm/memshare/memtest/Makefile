# SPDX-FileCopyrightText: 2022 TII

.PHONY: install default

default: memtest

install: memtest
	mkdir -p $(out)
	cp $< $(out)

memtest: memtest.c
