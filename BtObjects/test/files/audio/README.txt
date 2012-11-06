Created with:

D3/F5:
rec d3.wav synth 4 pluck D3 repeat 4

A4:
rec a4.wav synth 2 pluck A4 repeat 10

Wav->MP3:
lame --preset cbr 96 d3.wav d3.mp3

id3v2 --TCOM Sox d3.mp3
id3v2 --TALB 'BTicino tests' d3.mp3
id3v2 --TDAT 2012 d3.mp3
id3v2 --TIT2 'D3 pluck' d3.mp3
id3v2 --TRCK '1' d3.mp3
id3v2 --TYER '2011' d3.mp3
id3v2 --genre 147 d3.mp3

Track, Genre and Title change for each MP3

Broken files:

dd if=a4.mp3 of=broken/1.mp3 bs=1024 count=4
