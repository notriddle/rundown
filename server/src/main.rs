extern crate ammonia;
extern crate comrak;
extern crate typed_arena;

use std::fmt::Debug;
use std::io;
use std::io::prelude::*;
use typed_arena::Arena;

fn die<E: Debug, T>(e: E) -> T {
    writeln!(io::stderr(), "error: {:?}", e).unwrap();
    std::process::exit(1)
}

fn read_netstring<R: io::BufRead>(r: &mut R, buf: &mut Vec<u8>) -> io::Result<()> {
    let mut length_buf = Vec::new();
    r.read_until(b':', &mut length_buf).map(|_| ())?;
    let colon = length_buf.pop()
        .ok_or_else(|| io::Error::new(io::ErrorKind::Other, "No ':'"))?;
    if colon != b':' {
        return Err(io::Error::new(io::ErrorKind::Other, "Did not get ':'"));
    }
    let length = String::from_utf8_lossy(&length_buf).parse()
        .map_err(|e| io::Error::new(io::ErrorKind::Other, e))?;
    length_buf.clear();
    buf.resize(length, b'0');
    r.read_exact(buf)
}

fn main() {
    let mut input_buf = Vec::new();
    let mut output_buf = Vec::new();
    let mut url_buf = Vec::new();
    let stdin = io::stdin();
    let mut stdin = stdin.lock();
    let stdout = io::stdout();
    let mut stdout = stdout.lock();
    let comrak_options = comrak::ComrakOptions {
        ext_strikethrough: true,
        ext_table: true,
        ext_autolink: true,
        ext_tasklist: true,
        ext_superscript: true,
        .. comrak::ComrakOptions::default()
    };
    loop {
        read_netstring(&mut stdin, &mut url_buf).unwrap_or_else(die);
        let url = String::from_utf8_lossy(&url_buf);
        let mut ammonia_options = ammonia::Builder::default();
        ammonia_options.url_relative(ammonia::UrlRelative::RewriteWithBase(&*url));
        read_netstring(&mut stdin, &mut input_buf).unwrap_or_else(die);
        let input = String::from_utf8_lossy(&input_buf);

        let arena = Arena::new();
        let output_root = comrak::parse_document(&arena, &input, &comrak_options);
        output_buf.clear();
        comrak::format_html(output_root, &comrak_options, &mut output_buf).unwrap_or_else(die);
        let output_document = ammonia_options.clean_from_reader(&mut &output_buf[..]).unwrap_or_else(die);
        output_buf.clear();
        output_document.write_to(&mut output_buf).unwrap_or_else(die);
        write!(stdout, "{}:", output_buf.len()).unwrap_or_else(die);
        stdout.write_all(&mut &output_buf[..]).unwrap_or_else(die);
        stdout.flush().unwrap_or_else(die);
    }
}
