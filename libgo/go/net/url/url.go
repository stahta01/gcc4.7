// Copyright 2009 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Package URL parses URLs and implements query escaping.
// See RFC 3986.
package url

import (
	"errors"
	"strconv"
	"strings"
)

// Error reports an error and the operation and URL that caused it.
type Error struct {
	Op  string
	URL string
	Err error
}

func (e *Error) Error() string { return e.Op + " " + e.URL + ": " + e.Err.Error() }

func ishex(c byte) bool {
	switch {
	case '0' <= c && c <= '9':
		return true
	case 'a' <= c && c <= 'f':
		return true
	case 'A' <= c && c <= 'F':
		return true
	}
	return false
}

func unhex(c byte) byte {
	switch {
	case '0' <= c && c <= '9':
		return c - '0'
	case 'a' <= c && c <= 'f':
		return c - 'a' + 10
	case 'A' <= c && c <= 'F':
		return c - 'A' + 10
	}
	return 0
}

type encoding int

const (
	encodePath encoding = 1 + iota
	encodeUserPassword
	encodeQueryComponent
	encodeFragment
)

type EscapeError string

func (e EscapeError) Error() string {
	return "invalid URL escape " + strconv.Quote(string(e))
}

// Return true if the specified character should be escaped when
// appearing in a URL string, according to RFC 2396.
// When 'all' is true the full range of reserved characters are matched.
func shouldEscape(c byte, mode encoding) bool {
	// RFC 2396 §2.3 Unreserved characters (alphanum)
	if 'A' <= c && c <= 'Z' || 'a' <= c && c <= 'z' || '0' <= c && c <= '9' {
		return false
	}
	// TODO: Update the character sets after RFC 3986.
	switch c {
	case '-', '_', '.', '!', '~', '*', '\'', '(', ')': // §2.3 Unreserved characters (mark)
		return false

	case '$', '&', '+', ',', '/', ':', ';', '=', '?', '@': // §2.2 Reserved characters (reserved)
		// Different sections of the URL allow a few of
		// the reserved characters to appear unescaped.
		switch mode {
		case encodePath: // §3.3
			// The RFC allows : @ & = + $ but saves / ; , for assigning
			// meaning to individual path segments. This package
			// only manipulates the path as a whole, so we allow those
			// last two as well. That leaves only ? to escape.
			return c == '?'

		case encodeUserPassword: // §3.2.2
			// The RFC allows ; : & = + $ , in userinfo, so we must escape only @ and /.
			// The parsing of userinfo treats : as special so we must escape that too.
			return c == '@' || c == '/' || c == ':'

		case encodeQueryComponent: // §3.4
			// The RFC reserves (so we must escape) everything.
			return true

		case encodeFragment: // §4.1
			// The RFC text is silent but the grammar allows
			// everything, so escape nothing.
			return false
		}
	}

	// Everything else must be escaped.
	return true
}

// QueryUnescape does the inverse transformation of QueryEscape, converting
// %AB into the byte 0xAB and '+' into ' ' (space). It returns an error if
// any % is not followed by two hexadecimal digits.
func QueryUnescape(s string) (string, error) {
	return unescape(s, encodeQueryComponent)
}

// unescape unescapes a string; the mode specifies
// which section of the URL string is being unescaped.
func unescape(s string, mode encoding) (string, error) {
	// Count %, check that they're well-formed.
	n := 0
	hasPlus := false
	for i := 0; i < len(s); {
		switch s[i] {
		case '%':
			n++
			if i+2 >= len(s) || !ishex(s[i+1]) || !ishex(s[i+2]) {
				s = s[i:]
				if len(s) > 3 {
					s = s[0:3]
				}
				return "", EscapeError(s)
			}
			i += 3
		case '+':
			hasPlus = mode == encodeQueryComponent
			i++
		default:
			i++
		}
	}

	if n == 0 && !hasPlus {
		return s, nil
	}

	t := make([]byte, len(s)-2*n)
	j := 0
	for i := 0; i < len(s); {
		switch s[i] {
		case '%':
			t[j] = unhex(s[i+1])<<4 | unhex(s[i+2])
			j++
			i += 3
		case '+':
			if mode == encodeQueryComponent {
				t[j] = ' '
			} else {
				t[j] = '+'
			}
			j++
			i++
		default:
			t[j] = s[i]
			j++
			i++
		}
	}
	return string(t), nil
}

// QueryEscape escapes the string so it can be safely placed
// inside a URL query.
func QueryEscape(s string) string {
	return escape(s, encodeQueryComponent)
}

func escape(s string, mode encoding) string {
	spaceCount, hexCount := 0, 0
	for i := 0; i < len(s); i++ {
		c := s[i]
		if shouldEscape(c, mode) {
			if c == ' ' && mode == encodeQueryComponent {
				spaceCount++
			} else {
				hexCount++
			}
		}
	}

	if spaceCount == 0 && hexCount == 0 {
		return s
	}

	t := make([]byte, len(s)+2*hexCount)
	j := 0
	for i := 0; i < len(s); i++ {
		switch c := s[i]; {
		case c == ' ' && mode == encodeQueryComponent:
			t[j] = '+'
			j++
		case shouldEscape(c, mode):
			t[j] = '%'
			t[j+1] = "0123456789ABCDEF"[c>>4]
			t[j+2] = "0123456789ABCDEF"[c&15]
			j += 3
		default:
			t[j] = s[i]
			j++
		}
	}
	return string(t)
}

// A URL represents a parsed URL (technically, a URI reference).
// The general form represented is:
//
//	scheme://[userinfo@]host/path[?query][#fragment]
//
// URLs that do not start with a slash after the scheme are interpreted as:
//
//	scheme:opaque[?query][#fragment]
//
type URL struct {
	Scheme   string
	Opaque   string    // encoded opaque data
	User     *Userinfo // username and password information
	Host     string
	Path     string
	RawQuery string // encoded query values, without '?'
	Fragment string // fragment for references, without '#'
}

// User returns a Userinfo containing the provided username
// and no password set.
func User(username string) *Userinfo {
	return &Userinfo{username, "", false}
}

// UserPassword returns a Userinfo containing the provided username
// and password.
// This functionality should only be used with legacy web sites.
// RFC 2396 warns that interpreting Userinfo this way
// ``is NOT RECOMMENDED, because the passing of authentication
// information in clear text (such as URI) has proven to be a
// security risk in almost every case where it has been used.''
func UserPassword(username, password string) *Userinfo {
	return &Userinfo{username, password, true}
}

// The Userinfo type is an immutable encapsulation of username and
// password details for a URL. An existing Userinfo value is guaranteed
// to have a username set (potentially empty, as allowed by RFC 2396),
// and optionally a password.
type Userinfo struct {
	username    string
	password    string
	passwordSet bool
}

// Username returns the username.
func (u *Userinfo) Username() string {
	return u.username
}

// Password returns the password in case it is set, and whether it is set.
func (u *Userinfo) Password() (string, bool) {
	if u.passwordSet {
		return u.password, true
	}
	return "", false
}

// String returns the encoded userinfo information in the standard form
// of "username[:password]".
func (u *Userinfo) String() string {
	s := escape(u.username, encodeUserPassword)
	if u.passwordSet {
		s += ":" + escape(u.password, encodeUserPassword)
	}
	return s
}

// Maybe rawurl is of the form scheme:path.
// (Scheme must be [a-zA-Z][a-zA-Z0-9+-.]*)
// If so, return scheme, path; else return "", rawurl.
func getscheme(rawurl string) (scheme, path string, err error) {
	for i := 0; i < len(rawurl); i++ {
		c := rawurl[i]
		switch {
		case 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z':
		// do nothing
		case '0' <= c && c <= '9' || c == '+' || c == '-' || c == '.':
			if i == 0 {
				return "", rawurl, nil
			}
		case c == ':':
			if i == 0 {
				return "", "", errors.New("missing protocol scheme")
			}
			return rawurl[0:i], rawurl[i+1:], nil
		default:
			// we have encountered an invalid character,
			// so there is no valid scheme
			return "", rawurl, nil
		}
	}
	return "", rawurl, nil
}

// Maybe s is of the form t c u.
// If so, return t, c u (or t, u if cutc == true).
// If not, return s, "".
func split(s string, c byte, cutc bool) (string, string) {
	for i := 0; i < len(s); i++ {
		if s[i] == c {
			if cutc {
				return s[0:i], s[i+1:]
			}
			return s[0:i], s[i:]
		}
	}
	return s, ""
}

// Parse parses rawurl into a URL structure.
// The string rawurl is assumed not to have a #fragment suffix.
// (Web browsers strip #fragment before sending the URL to a web server.)
// The rawurl may be relative or absolute.
func Parse(rawurl string) (url *URL, err error) {
	return parse(rawurl, false)
}

// ParseRequest parses rawurl into a URL structure.  It assumes that
// rawurl was received from an HTTP request, so the rawurl is interpreted
// only as an absolute URI or an absolute path.
// The string rawurl is assumed not to have a #fragment suffix.
// (Web browsers strip #fragment before sending the URL to a web server.)
func ParseRequest(rawurl string) (url *URL, err error) {
	return parse(rawurl, true)
}

// parse parses a URL from a string in one of two contexts.  If
// viaRequest is true, the URL is assumed to have arrived via an HTTP request,
// in which case only absolute URLs or path-absolute relative URLs are allowed.
// If viaRequest is false, all forms of relative URLs are allowed.
func parse(rawurl string, viaRequest bool) (url *URL, err error) {
	var rest string

	if rawurl == "" {
		err = errors.New("empty url")
		goto Error
	}
	url = new(URL)

	// Split off possible leading "http:", "mailto:", etc.
	// Cannot contain escaped characters.
	if url.Scheme, rest, err = getscheme(rawurl); err != nil {
		goto Error
	}

	rest, url.RawQuery = split(rest, '?', true)

	if !strings.HasPrefix(rest, "/") {
		if url.Scheme != "" {
			// We consider rootless paths per RFC 3986 as opaque.
			url.Opaque = rest
			return url, nil
		}
		if viaRequest {
			err = errors.New("invalid URI for request")
			goto Error
		}
	}

	if (url.Scheme != "" || !viaRequest) && strings.HasPrefix(rest, "//") && !strings.HasPrefix(rest, "///") {
		var authority string
		authority, rest = split(rest[2:], '/', false)
		url.User, url.Host, err = parseAuthority(authority)
		if err != nil {
			goto Error
		}
		if strings.Contains(url.Host, "%") {
			err = errors.New("hexadecimal escape in host")
			goto Error
		}
	}
	if url.Path, err = unescape(rest, encodePath); err != nil {
		goto Error
	}
	return url, nil

Error:
	return nil, &Error{"parse", rawurl, err}
}

func parseAuthority(authority string) (user *Userinfo, host string, err error) {
	if strings.Index(authority, "@") < 0 {
		host = authority
		return
	}
	userinfo, host := split(authority, '@', true)
	if strings.Index(userinfo, ":") < 0 {
		if userinfo, err = unescape(userinfo, encodeUserPassword); err != nil {
			return
		}
		user = User(userinfo)
	} else {
		username, password := split(userinfo, ':', true)
		if username, err = unescape(username, encodeUserPassword); err != nil {
			return
		}
		if password, err = unescape(password, encodeUserPassword); err != nil {
			return
		}
		user = UserPassword(username, password)
	}
	return
}

// ParseWithReference is like Parse but allows a trailing #fragment.
func ParseWithReference(rawurlref string) (url *URL, err error) {
	// Cut off #frag
	rawurl, frag := split(rawurlref, '#', true)
	if url, err = Parse(rawurl); err != nil {
		return nil, err
	}
	if frag == "" {
		return url, nil
	}
	if url.Fragment, err = unescape(frag, encodeFragment); err != nil {
		return nil, &Error{"parse", rawurlref, err}
	}
	return url, nil
}

// String reassembles the URL into a valid URL string.
func (u *URL) String() string {
	// TODO: Rewrite to use bytes.Buffer
	result := ""
	if u.Scheme != "" {
		result += u.Scheme + ":"
	}
	if u.Opaque != "" {
		result += u.Opaque
	} else {
		if u.Host != "" || u.User != nil {
			result += "//"
			if u := u.User; u != nil {
				result += u.String() + "@"
			}
			result += u.Host
		}
		result += escape(u.Path, encodePath)
	}
	if u.RawQuery != "" {
		result += "?" + u.RawQuery
	}
	if u.Fragment != "" {
		result += "#" + escape(u.Fragment, encodeFragment)
	}
	return result
}

// Values maps a string key to a list of values.
// It is typically used for query parameters and form values.
// Unlike in the http.Header map, the keys in a Values map
// are case-sensitive.
type Values map[string][]string

// Get gets the first value associated with the given key.
// If there are no values associated with the key, Get returns
// the empty string. To access multiple values, use the map
// directly.
func (v Values) Get(key string) string {
	if v == nil {
		return ""
	}
	vs, ok := v[key]
	if !ok || len(vs) == 0 {
		return ""
	}
	return vs[0]
}

// Set sets the key to value. It replaces any existing
// values.
func (v Values) Set(key, value string) {
	v[key] = []string{value}
}

// Add adds the key to value. It appends to any existing
// values associated with key.
func (v Values) Add(key, value string) {
	v[key] = append(v[key], value)
}

// Del deletes the values associated with key.
func (v Values) Del(key string) {
	delete(v, key)
}

// ParseQuery parses the URL-encoded query string and returns
// a map listing the values specified for each key.
// ParseQuery always returns a non-nil map containing all the
// valid query parameters found; err describes the first decoding error
// encountered, if any.
func ParseQuery(query string) (m Values, err error) {
	m = make(Values)
	err = parseQuery(m, query)
	return
}

func parseQuery(m Values, query string) (err error) {
	for query != "" {
		key := query
		if i := strings.IndexAny(key, "&;"); i >= 0 {
			key, query = key[:i], key[i+1:]
		} else {
			query = ""
		}
		if key == "" {
			continue
		}
		value := ""
		if i := strings.Index(key, "="); i >= 0 {
			key, value = key[:i], key[i+1:]
		}
		key, err1 := QueryUnescape(key)
		if err1 != nil {
			err = err1
			continue
		}
		value, err1 = QueryUnescape(value)
		if err1 != nil {
			err = err1
			continue
		}
		m[key] = append(m[key], value)
	}
	return err
}

// Encode encodes the values into ``URL encoded'' form.
// e.g. "foo=bar&bar=baz"
func (v Values) Encode() string {
	if v == nil {
		return ""
	}
	parts := make([]string, 0, len(v)) // will be large enough for most uses
	for k, vs := range v {
		prefix := QueryEscape(k) + "="
		for _, v := range vs {
			parts = append(parts, prefix+QueryEscape(v))
		}
	}
	return strings.Join(parts, "&")
}

// resolvePath applies special path segments from refs and applies
// them to base, per RFC 2396.
func resolvePath(basepath string, refpath string) string {
	base := strings.Split(basepath, "/")
	refs := strings.Split(refpath, "/")
	if len(base) == 0 {
		base = []string{""}
	}
	for idx, ref := range refs {
		switch {
		case ref == ".":
			base[len(base)-1] = ""
		case ref == "..":
			newLen := len(base) - 1
			if newLen < 1 {
				newLen = 1
			}
			base = base[0:newLen]
			base[len(base)-1] = ""
		default:
			if idx == 0 || base[len(base)-1] == "" {
				base[len(base)-1] = ref
			} else {
				base = append(base, ref)
			}
		}
	}
	return strings.Join(base, "/")
}

// IsAbs returns true if the URL is absolute.
func (u *URL) IsAbs() bool {
	return u.Scheme != ""
}

// Parse parses a URL in the context of a base URL.  The URL in ref
// may be relative or absolute.  Parse returns nil, err on parse
// failure, otherwise its return value is the same as ResolveReference.
func (base *URL) Parse(ref string) (*URL, error) {
	refurl, err := Parse(ref)
	if err != nil {
		return nil, err
	}
	return base.ResolveReference(refurl), nil
}

// ResolveReference resolves a URI reference to an absolute URI from
// an absolute base URI, per RFC 2396 Section 5.2.  The URI reference
// may be relative or absolute.  ResolveReference always returns a new
// URL instance, even if the returned URL is identical to either the
// base or reference. If ref is an absolute URL, then ResolveReference
// ignores base and returns a copy of ref.
func (base *URL) ResolveReference(ref *URL) *URL {
	if ref.IsAbs() {
		url := *ref
		return &url
	}
	// relativeURI = ( net_path | abs_path | rel_path ) [ "?" query ]
	url := *base
	url.RawQuery = ref.RawQuery
	url.Fragment = ref.Fragment
	if ref.Opaque != "" {
		url.Opaque = ref.Opaque
		url.User = nil
		url.Host = ""
		url.Path = ""
		return &url
	}
	if ref.Host != "" || ref.User != nil {
		// The "net_path" case.
		url.Host = ref.Host
		url.User = ref.User
	}
	if strings.HasPrefix(ref.Path, "/") {
		// The "abs_path" case.
		url.Path = ref.Path
	} else {
		// The "rel_path" case.
		path := resolvePath(base.Path, ref.Path)
		if !strings.HasPrefix(path, "/") {
			path = "/" + path
		}
		url.Path = path
	}
	return &url
}

// Query parses RawQuery and returns the corresponding values.
func (u *URL) Query() Values {
	v, _ := ParseQuery(u.RawQuery)
	return v
}

// RequestURI returns the encoded path?query or opaque?query
// string that would be used in an HTTP request for u.
func (u *URL) RequestURI() string {
	result := u.Opaque
	if result == "" {
		result = escape(u.Path, encodePath)
		if result == "" {
			result = "/"
		}
	}
	if u.RawQuery != "" {
		result += "?" + u.RawQuery
	}
	return result
}
