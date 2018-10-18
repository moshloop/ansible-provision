docs:
	pip install mkdocs mkdocs-material pymdown-extensions Pygments
	git remote add docs "https://$(GH_TOKEN)@github.com/moshloop/ansible-provision.git"
	git fetch docs && git fetch docs gh-pages:gh-pages
	mkdocs gh-deploy -v --remote-name docs


setup:
	pip install awscli ansible-dependencies[all] ansible==2.6.5

test: setup
	./tests/test.sh $(test) -v