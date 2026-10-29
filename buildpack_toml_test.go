package nodeengine_test

import (
	"testing"

	"github.com/paketo-buildpacks/packit/v2/cargo"
	"github.com/paketo-buildpacks/packit/v2/postal"
	"github.com/sclevine/spec"

	. "github.com/onsi/gomega"
)

func testBuildpackTOML(t *testing.T, context spec.G, it spec.S) {
	var (
		Expect = NewWithT(t).Expect

		service postal.Service
	)

	it.Before(func() {
		t.Setenv("CNB_TARGET_OS", "linux")
		t.Setenv("CNB_TARGET_ARCH", "arm64")
		service = postal.NewService(cargo.NewTransport())
	})

	context("Node 26", func() {
		it("resolves on the plucky stack", func() {
			dependency, err := service.Resolve("buildpack.toml", "node", "26.*", "io.buildpacks.stacks.plucky")
			Expect(err).NotTo(HaveOccurred())
			Expect(dependency.Version).To(Equal("26.12.1"))
		})

		it("is not offered on stacks without libatomic", func() {
			for _, stack := range []string{"io.buildpacks.stacks.jammy", "io.buildpacks.stacks.noble"} {
				_, err := service.Resolve("buildpack.toml", "node", "26.*", stack)
				Expect(err).To(HaveOccurred(), stack)

				dependency, err := service.Resolve("buildpack.toml", "node", ">=20", stack)
				Expect(err).NotTo(HaveOccurred(), stack)
				Expect(dependency.Version).To(Equal("24.22.1"), stack)
			}
		})
	})
}
