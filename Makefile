docs:
	pip install mkdocs mkdocs-material pymdown-extensions Pygments
	git remote add docs "https://$(GH_TOKEN)@github.com/moshloop/ansible-provision.git"
	git fetch docs && git fetch docs gh-pages:gh-pages
	mkdocs gh-deploy -v --remote-name docs

tmp := $(shell mktemp)

ssh-agent:
	$(shell eval $(ssh-agent))
	rm $(tmp)
	ssh-keygen -f $(tmp) -N ""
	ssh-add $(tmp)

setup: ssh-agent
	pip install ansible-run


test: setup
	./tests/test.sh $(test) -v