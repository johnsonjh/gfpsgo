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

package process

import (
	"testing"

	"github.com/stretchr/testify/assert"
	u "go.gridfinity.dev/leaktestfe"
)

func TestAll(t *testing.T) {
	u.Leakplug(t)
	// no thorough test but it makes sure things are working
	p, err := New("self", false)
	assert.Nil(t, err)

	assert.NotNil(t, p.Stat)
	assert.NotNil(t, p.Status)
	assert.NotNil(t, p.CmdLine)
	assert.True(t, len(p.PidNS) > 0)
	assert.True(t, len(p.Label) > 0)

	err = p.SetHostData()
	assert.Nil(t, err)
	assert.True(t, len(p.Huser) > 0)
	assert.True(t, len(p.Hgroup) > 0)
}
