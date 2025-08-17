{{- define "multifile" -}}
- A list of file names followed by the code for that file
- file names are prefixed with FILENAME:
- Write raw code without extra quotes or comments
- Example:
FILENAME: fileName.txt
package restapi

import (
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
)
{{- end -}}
