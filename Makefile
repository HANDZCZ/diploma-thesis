convert:
	docker run -it --rm -v "$$(pwd):/home/user/thesis" handz/pandoc-toolkit:3.1.2 "./create_thesis.sh"

count-words:
	docker run -it --rm -v "$$(pwd):/home/user/thesis" handz/pandoc-toolkit:3.1.2 "./create_thesis.sh" --count-words-only

count-all:
	docker run -it --rm -v "$$(pwd):/home/user/thesis" handz/pandoc-toolkit:3.1.2 "./create_thesis.sh" --count-words-only --count-codeblocks

