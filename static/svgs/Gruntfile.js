module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-svgstore');

  grunt.initConfig({
    svgstore: {
      options: {
        prefix : 'features-',
        svg: {
          viewBox : '0 0 100 100',
          xmlns: 'http://www.w3.org/2000/svg'
        }
      },
      default: {
        files: {
          '../../_includes/generated/features.svg': ['features/*.svg']
        }
      }
    }
  });

  grunt.registerTask('default', ['svgstore'])
};