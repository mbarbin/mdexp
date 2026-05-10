.PHONY: build build-books build-site serve clean

build: build-books build-site

build-books:
	mdbook build book/introduction-to-mdexp
	cd ../test && mdbook build

build-site:
	zola build

serve: build-books
	zola serve

clean:
	rm -rf static/book public
