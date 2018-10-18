docs:
	pip install mkdocs mkdocs-material pymdown-extensions Pygments
	git remote add docs "https://$(GH_TOKEN)@github.com/moshloop/ansible-provision.git"
	git fetch docs && git fetch docs gh-pages:gh-pages
	mkdocs gh-deploy -v --remote-name docs


setup:
	wget -nv https://github.com/moshloop/ansible-dependencies/releases/download/2.6.5.5/portable-ansible-py3_2.6.5_amd64.deb
	pip install awscli
	sudo dpkg -i portable-ansible-py3_2.6.5_amd64.deb


test: setup
	./tests/test.sh $(test) -v