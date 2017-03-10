"use strict";
var grunt = require('grunt');
require('load-grunt-tasks')(grunt);

var branch=process.env.sourcebranch;
var folder=grunt.option('folder')||branch||'.';
var solutionjsonfiles = [`${folder}/**/*.json`,`!${folder}/node_modules/**/*.json`];
var createUIDefinition=`${folder}/createUIDefinition.json`;

grunt.initConfig({
    fileExists: {
            scripts: [`${folder}/mainTemplate.json`]
    },
    uidef: grunt.file.readJSON(createUIDefinition),
    jsonlint: {
        all: {
            src: solutionjsonfiles
        }
    },
    tv4: {
        options: {
            root: 'https://schema.management.azure.com/schemas/<%=uidef.version %>/CreateUIDefinition.MultiVm.json',
            multi: true,
            banUnknownProperties: true
        },
        myTarget: {
            src: [createUIDefinition]
        }
    }
});

grunt.task.registerTask("test", ["fileExists","jsonlint","tv4"]);
