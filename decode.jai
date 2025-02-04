#import "Basic";
#import "File";

main :: () {
    options := get_command_line_arguments();

    if options.count != 2 {
        print("Please specify a single file to decode.\n");
        return;
    }

    file_path := options[1];

    file_data, success := read_entire_file(file_path);
    if !success return;

    print("; % disassembly:\n", file_path);
    print("bits 16\n");

    while file_data {
        assert(file_data.count % 2 == 0);

        context.print_style.default_format_int.base = 2;

        assert(file_data[0] >> 2 == 0b100010);  // Instruction must be a MOV.

        dst  := (file_data[0] >> 1 & 1);
        wide := (file_data[0] >> 0 & 1);
        mod  := (file_data[1] >> 6 & 0b11);

        assert(mod == 0b11);  // Instruction must be register-to-register.

        src_index := file_data[1] >> 3 & 0b111;
        dst_index := file_data[1] >> 0 & 0b111;

        if dst  Swap(*src_index, *dst_index);

        src_name := register_table[src_index][wide];
        dst_name := register_table[dst_index][wide];

        print("mov %, %\n", dst_name, src_name);

        advance(*file_data, 2);
    }
}

register_table :: [2]string.[
    .["al", "ax"],
    .["cl", "cx"],
    .["dl", "dx"],
    .["bl", "bx"],
    .["ah", "sp"],
    .["ch", "bp"],
    .["dh", "si"],
    .["bh", "di"],
];
