module VMLinuxBindings
    using CBinding

    @static if Sys.islinux()
        vmlinux_iob = IOBuffer()
        run(pipeline(`bpftool btf dump file /sys/kernel/btf/vmlinux format c`; stdout=vmlinux_iob))
        vmlinux_str = String(take!(vmlinux_iob))

        vmlinux_path = joinpath(@__DIR__, "vmlinux.h")
        open(vmlinux_path, "w") do io
            write(io, vmlinux_str)
            flush(io)
        end

        @eval c`-std=c99 -fparse-all-comments -I$(@__DIR__)`
        @eval c"#include \"vmlinux.h\""
    end
end
