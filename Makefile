all : lisper-vim.zip

remove-zip:
	-rm doc/tags
	-rm lisper-vim.zip

lisper-vim.zip: remove-zip
	zip -r lisper-vim.zip autoload plugin doc example

release: lisper-vim.zip
	vimup update-script lisper.vim
