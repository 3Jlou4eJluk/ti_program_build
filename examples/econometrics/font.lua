-- 14 rows per glyph, one hex byte per row, leftmost pixel at bit 7.
-- Rasterized from Noto Sans Mono Regular at 12 px with FreeType mono hinting.
-- The copyright notice and SIL Open Font License follow the bitmap data.
local bitmaps = {
    [" "] = "0000000000000000000000000000",
    ["!"] = "0000808080808080008080000000",
    ["\""] = "0000a0a0a0000000000000000000",
    ["#"] = "000014247e2828fe284858000000",
    ["$"] = "002078a0a060382828f020000000",
    ["%"] = "0000e4a4a868101e2a2a4e000000",
    ["&"] = "0000304848302056cc4c76000000",
    ["'"] = "0000808080000000000000000000",
    ["("] = "000020404040c080c04040402000",
    [")"] = "0000804040202020202040408000",
    ["*"] = "002020f830580000000000000000",
    ["+"] = "000000202020f820200000000000",
    [","] = "00000000000000000000c0808000",
    ["-"] = "00000000000000e0000000000000",
    ["."] = "0000000000000000008080000000",
    ["/"] = "00000810102020204040c0000000",
    ["0"] = "000070889898a8e8c88870000000",
    ["1"] = "000020e020202020202078000000",
    ["2"] = "000070880808103060c0fc000000",
    ["3"] = "0000f088081870080808f0000000",
    ["4"] = "000010303050d090fc1010000000",
    ["5"] = "0000f88080f008080888f0000000",
    ["6"] = "0000384080f08888888870000000",
    ["7"] = "0000f80808101010202040000000",
    ["8"] = "0000708888587088888870000000",
    ["9"] = "0000708888888878081870000000",
    [":"] = "0000000080800000008080000000",
    [";"] = "00000000c0c000000000c0808000",
    ["<"] = "0000000830c06018080000000000",
    ["="] = "0000000000f800f8000000000000",
    [">"] = "000000c0201830c0800000000000",
    ["?"] = "0000f08808083020002020000000",
    ["@"] = "00003c445aaaaaaab480443c0000",
    ["A"] = "000010182828247c444482000000",
    ["B"] = "0000f0888888f0888c88f8000000",
    ["C"] = "00003c408080808080c078000000",
    ["D"] = "0000f0888884848c8898f0000000",
    ["E"] = "0000f8808080f8808080f8000000",
    ["F"] = "0000f8808080f880808080000000",
    ["G"] = "000078c08080988888c878000000",
    ["H"] = "000088888888f888888888000000",
    ["I"] = "0000f820202020202020f8000000",
    ["J"] = "00001818181818181810f0000000",
    ["K"] = "00008890b0a0e0a090988c000000",
    ["L"] = "00008080808080808080f8000000",
    ["M"] = "00008cccd4d4d4a4a48484000000",
    ["N"] = "000088c8c8a8a898989888000000",
    ["O"] = "0000708888848484888870000000",
    ["P"] = "0000f8888c88f080808080000000",
    ["Q"] = "0000708888848484888870080800",
    ["R"] = "0000f0888888f09098888c000000",
    ["S"] = "000078c080c030080808f0000000",
    ["T"] = "0000fc2020202020202020000000",
    ["U"] = "0000888888888888888870000000",
    ["V"] = "0000c24444442428281810000000",
    ["W"] = "0000828252526c6c6c6464000000",
    ["X"] = "00004664281810282844c6000000",
    ["Y"] = "0000c64424281810101010000000",
    ["Z"] = "0000f8081010202040c0f8000000",
    ["["] = "0000e0808080808080808080e000",
    ["\\"] = "0000c04040202020101008000000",
    ["]"] = "0000c0404040404040404040c000",
    ["^"] = "000020505050888c000000000000",
    ["_"] = "000000000000000000000000fe00",
    ["`"] = "00c0600000000000000000000000",
    ["a"] = "00000000f08808788888f8000000",
    ["b"] = "00808080f0c8888c8888f0000000",
    ["c"] = "0000000078c0808080c078000000",
    ["d"] = "0008080878888888888878000000",
    ["e"] = "00000000708888f8808078000000",
    ["f"] = "001c2020f8202020202020000000",
    ["g"] = "00000000788888888888780808f0",
    ["h"] = "00808080b8c88888888888000000",
    ["i"] = "00202000e02020202020f8000000",
    ["j"] = "00303000701010101010101030e0",
    ["k"] = "008080808c90b0a0d0888c000000",
    ["l"] = "00e02020202020202020f8000000",
    ["m"] = "00000000f8a4a4a4a4a4a4000000",
    ["n"] = "00000000b8c88888888888000000",
    ["o"] = "000000007088888c888870000000",
    ["p"] = "00000000f088888c8888f0808080",
    ["q"] = "0000000078888888888878080808",
    ["r"] = "00000000fc2020202020f8000000",
    ["s"] = "00000000788040300808f0000000",
    ["t"] = "00002060f8606060606038000000",
    ["u"] = "0000000088888888888878000000",
    ["v"] = "000000008c888850505020000000",
    ["w"] = "000000008292526a6c6c64000000",
    ["x"] = "000000008c58502050588c000000",
    ["y"] = "000000008c8848505030202020c0",
    ["z"] = "00000000f81810206040f8000000",
    ["{"] = "0000304040404080404040403000",
    ["|"] = "0080808080808080808080808080",
    ["}"] = "0000804040404030404040408000",
    ["~"] = "0000000000e89800000000000000",
    ["«"] = "00000000002858b0506800000000",
    ["±"] = "000000202020f8202000f8000000",
    ["²"] = "e020204080e00000000000000000",
    ["·"] = "0000000000008080000000000000",
    ["¹"] = "c0404040e0000000000000000000",
    ["»"] = "0000000000b0506858b000000000",
    ["×"] = "0000000088502050880000000000",
    ["Δ"] = "00001018282824444442fe000000",
    ["Σ"] = "0000f840602030204040f8000000",
    ["Φ"] = "0000103c5452d252543c10000000",
    ["α"] = "000000007888888888887c000000",
    ["β"] = "0070888888b088848488f8808080",
    ["γ"] = "000000008c88c850503020202020",
    ["δ"] = "007848402078888c8c8870000000",
    ["ρ"] = "000000007088888c8888f0808080",
    ["σ"] = "000000007c88888c888870000000",
    ["τ"] = "00000000f8202020202038000000",
    ["φ"] = "00000000f8a8acaca8a870202020",
    ["χ"] = "00000000c848503020205050908c",
    ["Ё"] = "5800f8808080f8808080f8000000",
    ["А"] = "000010182828247c444482000000",
    ["Б"] = "0000f88080f0888c8c88f0000000",
    ["В"] = "0000f0888888f0888c88f8000000",
    ["Г"] = "0000fc8080808080808080000000",
    ["Д"] = "00003c24242424242444fe828200",
    ["Е"] = "0000f8808080f8808080f8000000",
    ["Ж"] = "0000925254543c54545292000000",
    ["З"] = "0000f008080870080808f0000000",
    ["И"] = "000088989898a8a8c8c888000000",
    ["Й"] = "f088989898a8a8c8c88800000000",
    ["К"] = "0000888890a0e0b090888c000000",
    ["Л"] = "00003c24242424242424c4000000",
    ["М"] = "00008cccd4d4d4a4a48484000000",
    ["Н"] = "000088888888f888888888000000",
    ["О"] = "0000708888848484888870000000",
    ["П"] = "0000f88888888888888888000000",
    ["Р"] = "0000f8888c88f080808080000000",
    ["С"] = "00003c4080808080804038000000",
    ["Т"] = "0000fc2020202020202020000000",
    ["У"] = "0000c24444242818101060000000",
    ["Ф"] = "0000107c56929292563c10000000",
    ["Х"] = "00004664281810282844c6000000",
    ["Ц"] = "00008888888888888888fc040400",
    ["Ч"] = "0000888888888878080808000000",
    ["Ш"] = "0000a4a4a4a4a4a4a4a4fc000000",
    ["Щ"] = "00009494949494949494fe020200",
    ["Ъ"] = "0000e02020382426262438000000",
    ["Ы"] = "0000848484e4b49494b4e4000000",
    ["Ь"] = "0000808080f088888888f0000000",
    ["Э"] = "0000f01808087c080818f0000000",
    ["Ю"] = "000098aca4a4e4a4a4ac98000000",
    ["Я"] = "00003c4444443c342444c4000000",
    ["а"] = "00000000f08808788888f8000000",
    ["б"] = "384080f088888c88887000000000",
    ["в"] = "00000000f88888f08888f8000000",
    ["г"] = "00000000f0808080808080000000",
    ["д"] = "000000003c2424242444fe828200",
    ["е"] = "00000000708888fc808078000000",
    ["ж"] = "00000000d2545438545492000000",
    ["з"] = "00000000f00808700808f0000000",
    ["и"] = "00000000889898a8a8c888000000",
    ["й"] = "00907000889898a8a8c888000000",
    ["к"] = "000000008c9890e090988c000000",
    ["л"] = "000000003c2424242424c4000000",
    ["м"] = "000000008cccd4d4d4a4a4000000",
    ["н"] = "00000000888888f8888888000000",
    ["о"] = "000000007088888c888870000000",
    ["п"] = "00000000f8888888888888000000",
    ["р"] = "00000000f088888c8888f0808080",
    ["с"] = "000000007840808080c078000000",
    ["т"] = "00000000f8202020202020000000",
    ["у"] = "000000008c8848505030202020c0",
    ["ф"] = "0020202078a8a4a4aca870202020",
    ["х"] = "000000008c58702050588c000000",
    ["ц"] = "00000000888888888888fc040400",
    ["ч"] = "0000000088888888780808000000",
    ["ш"] = "00000000a4a4a4a4a4a4fc000000",
    ["щ"] = "00000000a4a4a4a4a4a4fc040400",
    ["ъ"] = "00000000e020203c24243c000000",
    ["ы"] = "00000000848484e49494e4000000",
    ["ь"] = "00000000808080f88888f8000000",
    ["э"] = "00000000f01808780818f0000000",
    ["ю"] = "00000000b8aca4e4a4a8b8000000",
    ["я"] = "0000000078888878484888000000",
    ["ё"] = "00d0d000708888fc808078000000",
    ["ᵀ"] = "0000f04040404000000000000000",
    ["ᵢ"] = "0000000000004000c04040e00000",
    ["–"] = "00000000000000f8000000000000",
    ["—"] = "00000000000000fe000000000000",
    ["…"] = "000000000000000000a8a8000000",
    ["⁻"] = "000000e000000000000000000000",
    ["₀"] = "00000000000000e0a09090a0e000",
    ["₁"] = "00000000000000c0404040e00000",
    ["₋"] = "000000000000000000e000000000",
    ["ₜ"] = "0000000000004040e04040600000",
    ["←"] = "000000000000000040f840000000",
    ["↑"] = "0000000040e04040404040000000",
    ["→"] = "000000000000000010f810000000",
    ["↓"] = "000000004040404040e040000000",
    ["−"] = "000000000000f800000000000000",
    ["≈"] = "0000000000e8b8e8b80000000000",
    ["≠"] = "0000001010f820f8404000000000",
    ["≥"] = "000000c0300830c000f800000000",
    ["►"] = "00000080e0f8fef8e08000000000",
    ["ⱼ"] = "00000000000020006020202020e0",
}

--[=[
Copyright 2022 The Noto Project Authors (https://github.com/notofonts/latin-greek-cyrillic)

This Font Software is licensed under the SIL Open Font License,
Version 1.1.

This license is copied below, and is also available with a FAQ at:
http://scripts.sil.org/OFL

-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font
creation efforts of academic and linguistic communities, and to
provide a free and open framework in which fonts may be shared and
improved in partnership with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded,
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply to
any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software
components as distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to,
deleting, or substituting -- in part or in whole -- any of the
components of the Original Version, by changing formats or by porting
the Font Software to a new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed,
modify, redistribute, and sell modified and unmodified copies of the
Font Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components, in
Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the
corresponding Copyright Holder. This restriction only applies to the
primary font name as presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created using
the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.
]=]

return bitmaps
