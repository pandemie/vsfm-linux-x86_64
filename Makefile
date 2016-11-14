
all: vsfm/bin/VisualSFM vsfm/bin/libsiftgpu.so vsfm/bin/libpba.so

run: all
	LD_LIBRARY_PATH=./vsfm/bin:$$LD_LIBRARY_PATH vsfm/bin/VisualSFM

vsfm/bin/libpba.so: pba/bin/libpba.so
	ln -s ../../$< $@

pba/bin/libpba.so: pba
	cd $< && make -f makefile CUDA_BIN_PATH=/usr/bin -j 1

pba: pba_v1.0.5.zip
	unzip $<
	sed -i 's#CUDA_INC_PATH = $$(CUDA_INSTALL_PATH)/include#CUDA_INC_PATH = /usr/include#g' pba/makefile
	sed -i 's#CUDA_LIB_PATH = $$(CUDA_INSTALL_PATH)/lib64#CUDA_LIB_PATH = /usr/lib/x86_64-linux-gnu#g' pba/makefile
	sed -i 's/NVCC_FLAGS = -I$$(CUDA_INC_PATH) -O2 -Xcompiler -fPIC/NVCC_FLAGS = -D_FORCE_INLINES -I$$(CUDA_INC_PATH) -O2 -Xcompiler -fPIC/g' pba/makefile

pba_v1.0.5.zip:
	wget http://grail.cs.washington.edu/projects/mcba/pba_v1.0.5.zip

vsfm/bin/libsiftgpu.so: SiftGPU/bin/libsiftgpu.so
	ln -s ../../$< $@

SiftGPU/bin/libsiftgpu.so: SiftGPU
	cd $< && make siftgpu_enable_cuda=1 CUDA_BIN_PATH=/usr/bin CUDA_INC_PATH=/usr

SiftGPU: SiftGPU.zip
	unzip $<
	sed -i 's/siftgpu_enable_cuda = 0/siftgpu_enable_cuda = 1/g' SiftGPU/makefile
	sed -i 's#CUDA_LIB_PATH = $$(CUDA_INSTALL_PATH)/lib64 -L$$(CUDA_INSTALL_PATH)/lib#CUDA_LIB_PATH = /usr/lib/x86_64-linux-gnu#g' SiftGPU/makefile
	sed -i 's/NVCC_FLAGS = -I$$(INC_DIR) -I$$(CUDA_INC_PATH) -DCUDA_SIFTGPU_ENABLED -O2 -Xcompiler -fPIC/NVCC_FLAGS = -D_FORCE_INLINES -I$$(INC_DIR) -I$$(CUDA_INC_PATH) -DCUDA_SIFTGPU_ENABLED -O2 -Xcompiler -fPIC/g' SiftGPU/makefile


SiftGPU.zip:
	wget http://wwwx.cs.unc.edu/~ccwu/cgi-bin/siftgpu.cgi -O $@

vsfm/bin/VisualSFM: vsfm
	cd $< && make

vsfm: VisualSFM_linux_64bit.zip
	unzip $< && touch $@

VisualSFM_linux_64bit.zip:
	wget http://ccwu.me/vsfm/download/VisualSFM_linux_64bit.zip

install-reqs:
	sudo apt-get install libgtk2.0-dev freeglut3-dev libdevil-dev libglew-dev unzip

clean:
	$(RM) VisualSFM_linux_64bit.zip
	$(RM) SiftGPU.zip
	$(RM) pba_v1.0.5.zip
	$(RM) -r vsfm
	$(RM) -r SiftGPU
	$(RM) -r pba
