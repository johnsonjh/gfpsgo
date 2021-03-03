// Copyright 2021 Jeffrey H. Johnson <trnsz@pobox.com>
// Copyright 2018 psgo authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package proc

import (
	"testing"

	u "github.com/johnsonjh/leaktestfe"
	"github.com/stretchr/testify/assert"
)

func TestParseAttrCurrent(t *testing.T) {
	u.Leakplug(t)
	// no thorough test but it makes sure things are working
	_, err := ParseAttrCurrent("self")
	assert.Nil(t, err)
}
