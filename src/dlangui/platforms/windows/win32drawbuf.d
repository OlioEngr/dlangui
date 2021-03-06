module dlangui.platforms.windows.win32drawbuf;

version (Windows) {

import win32.windows;
import dlangui.core.logger;
import dlangui.graphics.drawbuf;

class Win32ColorDrawBuf : ColorDrawBufBase {
    uint * _pixels;
    HDC _drawdc;
    HBITMAP _drawbmp;
    @property HDC dc() { return _drawdc; }
    @property HBITMAP bmp() { return _drawdc; }
    this(int width, int height) {
        resize(width, height);
    }
	/// create resized copy of ColorDrawBuf
	this(ColorDrawBuf v, int dx, int dy) {
		this(dx, dy);
        fill(0xFFFFFFFF);
        if (_dx == dx && _dy == dy)
            drawImage(0, 0, v);
        else
            drawRescaled(Rect(0, 0, dx, dy), v, Rect(0, 0, v.width, v.height));
	}
	void invertAlpha() {
		for(int i = _dx * _dy - 1; i >= 0; i--)
			_pixels[i] ^= 0xFF000000;
	}
    /// returns HBITMAP for alpha
    HBITMAP createTransparencyBitmap() {
        int hbytes = (((_dx + 7) / 8) + 1) & 0xFFFFFFFE;
        static ubyte[] buf;
        buf.length = hbytes * _dy * 2;
        //for (int y = 0; y < _dy; y++) {
        //    uint * src = scanLine(y);
        //    ubyte * dst1 = buf.ptr + (_dy - 1 - y) * hbytes;
        //    ubyte * dst2 = buf.ptr + (_dy - 1 - y) * hbytes + hbytes * _dy;
        //    for (int x = 0; x < _dx; x++) {
        //        ubyte pixel1 = 0x80; //(src[x] >> 24) > 0x80 ? 0 : 0x80;
        //        ubyte pixel2 = (src[x] >> 24) < 0x80 ? 0 : 0x80;
        //        int xi = x >> 3;
        //        dst1[xi] |= (pixel1 >> (x & 7));
        //        dst2[xi] |= (pixel2 >> (x & 7));
        //    }
        //}
        // debug
        for(int i = 0; i < hbytes * _dy; i++)
            buf[i] = 0xFF;
        for(int i = hbytes * _dy; i < buf.length; i++)
            buf[i] = 0; //0xFF;

        BITMAP b;
        b.bmWidth = _dx;
        b.bmHeight = _dy;
        b.bmWidthBytes = hbytes;
        b.bmPlanes = 1;
        b.bmBitsPixel = 1;
        b.bmBits = buf.ptr;
        return CreateBitmapIndirect(&b);
        //return CreateBitmap(_dx, _dy, 1, 1, buf.ptr);
    }
    /// destroy object, but leave bitmap as is
    HBITMAP destoryLeavingBitmap() {
        HBITMAP res = _drawbmp;
        _drawbmp = null;
        destroy(this);
        return res;
    }
    override uint * scanLine(int y) {
        if (y >= 0 && y < _dy)
            return _pixels + _dx * (_dy - 1 - y);
        return null;
    }
    ~this() {
        clear();
    }
    override void clear() {
        if (_drawbmp !is null || _drawdc !is null) {
            if (_drawbmp)
                DeleteObject(_drawbmp);
            if (_drawdc)
                DeleteObject(_drawdc);
            _drawbmp = null;
            _drawdc = null;
            _pixels = null;
            _dx = 0;
            _dy = 0;
        }
    }
    override void resize(int width, int height) {
        if (width< 0)
            width = 0;
        if (height < 0)
            height = 0;
        if (_dx == width && _dy == height)
            return;
        clear();
        _dx = width;
        _dy = height;
        if (_dx > 0 && _dy > 0) {
            BITMAPINFO bmi;
            //memset( &bmi, 0, sizeof(bmi) );
            bmi.bmiHeader.biSize = (bmi.bmiHeader.sizeof);
            bmi.bmiHeader.biWidth = _dx;
            bmi.bmiHeader.biHeight = _dy;
            bmi.bmiHeader.biPlanes = 1;
            bmi.bmiHeader.biBitCount = 32;
            bmi.bmiHeader.biCompression = BI_RGB;
            bmi.bmiHeader.biSizeImage = 0;
            bmi.bmiHeader.biXPelsPerMeter = 1024;
            bmi.bmiHeader.biYPelsPerMeter = 1024;
            bmi.bmiHeader.biClrUsed = 0;
            bmi.bmiHeader.biClrImportant = 0;
            _drawbmp = CreateDIBSection( NULL, &bmi, DIB_RGB_COLORS, cast(void**)(&_pixels), NULL, 0 );
            _drawdc = CreateCompatibleDC(NULL);
            SelectObject(_drawdc, _drawbmp);
        }
    }
    override void fill(uint color) {
        int len = _dx * _dy;
        for (int i = 0; i < len; i++)
            _pixels[i] = color;
    }
    void drawTo(HDC dc, int x, int y) {
        BitBlt(dc, x, y, _dx, _dy, _drawdc, 0, 0, SRCCOPY);
    }
}

}
