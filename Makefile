docs:
	pip install mkdocs mkdocs-material pymdown-extensions Pygments
	git remote add docs "https://$(GH_TOKEN)@github.com/moshloop/ansible-provision.git"
	git fetch docs && git fetch docs gh-pages:gh-pages
	mkdocs gh-deploy -v --remote-name docs
	python setup.py sdist
	twine upload dist/*.tar.gz || echo already exists

ssh-key:
	mkdir -p ~/.ssh
	ssh-keygen -f ~/.ssh/id_rsa -N ""

setup: ssh-key
	pip install ansible-run

test: setup
	./tests/test.sh $(test) -v