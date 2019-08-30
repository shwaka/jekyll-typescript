buildDir = ${TSBUILD}
nameList = $(shell find . -name "*.ts" | sed "s/\.ts//")
targetList = $(foreach name,$(nameList),$(buildDir)/$(name).js)

all: $(targetList)
clean:
	rm -r $(buildDir)

$(targetList): $(foreach name,$(nameList),$(name).ts)
	tsc --outDir $(buildDir)
