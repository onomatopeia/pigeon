# Tool macros
CC ?= gcc
CXX ?= g++

# Settings
NAME = app
BUILD_PATH = ./build

# Location of main.cpp (must use C++ compiler for main)
CXXSOURCES = src/main.cpp

# Path to edge-impulse-sdk
EDGE_IMPULSE_SDK_PATH = edge-impulse-sdk

# Search path for header files (current directory)
CFLAGS += -I.

# C and C++ Compiler flags
CFLAGS += -Wall						# Include all warnings
CFLAGS += -g						# Generate GDB debugger information
CFLAGS += -Wno-strict-aliasing		# Disable warnings about strict aliasing
CFLAGS += -Os						# Optimize for size
CFLAGS += -DNDEBUG					# Disable assert() macro
CFLAGS += -DEI_CLASSIFIER_ENABLE_DETECTION_POSTPROCESS_OP	# Add TFLite_Detection_PostProcess operation

# C++ only compiler flags
CXXFLAGS += -std=c++14				# Use C++14 standard

# Linker flags
LDFLAGS += -lm 						# Link to math.h
LDFLAGS += -lstdc++					# Link to stdc++.h

# Include C source code for required libraries
CSOURCES += $(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/TransformFunctions/*.c) \
			$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/CommonTables/*.c) \
			$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/BasicMathFunctions/*.c) \
			$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/ComplexMathFunctions/*.c) \
			$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/FastMathFunctions/*.c) \
			$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/SupportFunctions/*.c) \
			$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/MatrixFunctions/*.c) \
			$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/Source/StatisticsFunctions/*.c)

# Include C++ source code for required libraries
CXXSOURCES += 	$(wildcard tflite-model/*.cpp) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/dsp/kissfft/*.cpp) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/dsp/dct/*.cpp) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/dsp/memory.cpp) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/porting/posix/*.c*) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/porting/mingw32/*.c*)
CCSOURCES +=

# Use LiteRT (previously Tensorflow Lite) for Microcontrollers (TFLM)
CFLAGS += -DTF_LITE_DISABLE_X86_NEON=1
CSOURCES +=	$(EDGE_IMPULSE_SDK_PATH)/tensorflow/lite/c/common.c
CCSOURCES +=	$(wildcard $(EDGE_IMPULSE_SDK_PATH)/tensorflow/lite/kernels/*.cc) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/tensorflow/lite/kernels/internal/*.cc) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/tensorflow/lite/micro/kernels/*.cc) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/tensorflow/lite/micro/*.cc) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/tensorflow/lite/micro/memory_planner/*.cc) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/tensorflow/lite/core/api/*.cc)

# Include CMSIS-NN if compiling for an Arm target that supports it
ifeq (${CMSIS_NN}, 1)

	# Include CMSIS-NN and CMSIS-DSP header files
	CFLAGS += -I$(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Include/
	CFLAGS += -I$(EDGE_IMPULSE_SDK_PATH)/CMSIS/DSP/PrivateInclude/

	# C and C++ compiler flags for CMSIS-NN and CMSIS-DSP
	CFLAGS += -Wno-unknown-attributes 					# Disable warnings about unknown attributes
	CFLAGS += -DEI_CLASSIFIER_TFLITE_ENABLE_CMSIS_NN=1	# Use CMSIS-NN functions in the SDK
	CFLAGS += -D__ARM_FEATURE_DSP=1 					# Enable CMSIS-DSP optimized features
	CFLAGS += -D__GNUC_PYTHON__=1						# Enable CMSIS-DSP intrisics (non-C features)

	# Include C source code for required CMSIS libraries
	CSOURCES += $(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/ActivationFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/BasicMathFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/ConcatenationFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/ConvolutionFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/FullyConnectedFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/NNSupportFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/PoolingFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/ReshapeFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/SoftmaxFunctions/*.c) \
				$(wildcard $(EDGE_IMPULSE_SDK_PATH)/CMSIS/NN/Source/SVDFunctions/*.c)
endif

# Generate names for the output object files (*.o)
COBJECTS := $(patsubst %.c,%.o,$(CSOURCES))
CXXOBJECTS := $(patsubst %.cpp,%.o,$(CXXSOURCES))
CCOBJECTS := $(patsubst %.cc,%.o,$(CCSOURCES))

# Default rule
.PHONY: all
all: app

# Compile library source code into object files
$(COBJECTS) : %.o : %.c
$(CXXOBJECTS) : %.o : %.cpp
$(CCOBJECTS) : %.o : %.cc
%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@
%.o: %.cc
	$(CXX) $(CFLAGS) $(CXXFLAGS) -c $^ -o $@
%.o: %.cpp
	$(CXX) $(CFLAGS) $(CXXFLAGS) -c $^ -o $@

# Build target (must use C++ compiler)
.PHONY: app
app: $(COBJECTS) $(CXXOBJECTS) $(CCOBJECTS)
ifeq ($(OS), Windows_NT)
	if not exist build mkdir build
else
	mkdir -p $(BUILD_PATH)
endif
	$(CXX) $(COBJECTS) $(CXXOBJECTS) $(CCOBJECTS) -o $(BUILD_PATH)/$(NAME) $(LDFLAGS)

# Remove compiled object files
.PHONY: clean
clean:
ifeq ($(OS), Windows_NT)
	del /Q $(subst /,\,$(patsubst %.c,%.o,$(CSOURCES))) >nul 2>&1 || exit 0
	del /Q $(subst /,\,$(patsubst %.cpp,%.o,$(CXXSOURCES))) >nul 2>&1 || exit 0
	del /Q $(subst /,\,$(patsubst %.cc,%.o,$(CCSOURCES))) >nul 2>&1 || exit 0
else
	rm -f $(COBJECTS)
	rm -f $(CCOBJECTS)
	rm -f $(CXXOBJECTS)
endif
