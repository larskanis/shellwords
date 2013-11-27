require "ffi"

module Shell32
  ZeroZeroString = "\0\0"

  class ::FFI::AbstractMemory
    def to_s_utf16
      i = 0
      while self.get_bytes(i,2)!=ZeroZeroString
        i+=2
      end
      self.get_bytes(0,i)
    end

    def to_s_utf8
      return nil if null?
      to_s_utf16.encode(Encoding::UTF_8, Encoding::UTF_16LE)
    end
  end

  class ::String
    def to_s_win32
      FFI::MemoryPointer.from_string (self+"\0").encode(Encoding::UTF_16LE, Encoding::UTF_8)
    end
  end

  extend FFI::Library

  ffi_lib "shell32"
  ffi_convention :stdcall

  #   LPWSTR* CommandLineToArgvW(
  #     _In_   LPCWSTR lpCmdLine,
  #     _Out_  int *pNumArgs
  #   );
  attach_function :CommandLineToArgvW,
                  [ :pointer, :pointer ], :pointer

  def self.CommandLineToArgv(cmdline)
    lpCmdLine = cmdline.to_s_win32
    pNumArgs = FFI::MemoryPointer.new :int
    res = Shell32.CommandLineToArgvW(lpCmdLine, pNumArgs)
    raise "error in CommandLineToArgvW()" if res.null?

    res.read_array_of_pointer(pNumArgs.read_int).map do |ptr|
      ptr.to_s_utf8
    end
  end
end
