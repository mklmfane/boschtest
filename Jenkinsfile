import hudson.model.JDK
import hudson.tools.InstallSourceProperty
import hudson.tools.ZipExtractionInstaller
import jenkins.model.*
import org.jenkinsci.plugins.configfiles.maven.*
import org.jenkinsci.plugins.configfiles.maven.security.*
import hudson.tasks.Maven
import hudson.tasks.Maven.MavenInstallation;
import hudson.tools.InstallSourceProperty;
import hudson.tools.ToolProperty;
import hudson.tools.ToolPropertyDescriptor
import hudson.tools.ZipExtractionInstaller;
import hudson.util.DescribableList
import jenkins.model.Jenkins;

def List<JDK> installations = []

javaTools=[['name':'jdk8', 'url':'file:/var/jenkins_home/downloads/jdk-8u131-linux-x64.tar.gz', 'subdir':'jdk1.8.0_131'],
      ['name':'jdk7', 'url':'file:/var/jenkins_home/downloads/jdk-7u76-linux-x64.tar.gz', 'subdir':'jdk1.7.0_76']]

javaTools.each { javaTool ->

    println("Setting up tool: ${javaTool.name}")

    def installer = new ZipExtractionInstaller(javaTool.label as String, javaTool.url as String, javaTool.subdir as String);
    def jdk = new JDK(javaTool.name as String, null, [new InstallSourceProperty([installer])])
    installations.add(jdk)

}
descriptor.setInstallations(installations.toArray(new JDK[installations.size()]))
descriptor.save()

def descriptor = new JDK.DescriptorImpl();
def extensions = Jenkins.instance.getExtensionList(Maven.DescriptorImpl.class)[0]

List<MavenInstallation> installations = []

mavenToool = ['name': 'maven3', 'url': 'file:/var/jenkins_home/downloads/apache-maven-3.5.0-bin.tar.gz', 'subdir': 'apache-maven-3.5.0']

println("Setting up tool: ${mavenToool.name} ")

def describableList = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
def installer = new ZipExtractionInstaller(mavenToool.label as String, mavenToool.url as String, mavenToool.subdir as String);

describableList.add(new InstallSourceProperty([installer]))

installations.add(new MavenInstallation(mavenToool.name as String, "", describableList))

extensions.setInstallations(installations.toArray(new MavenInstallation[installations.size()]))
extensions.save()


def store = Jenkins.instance.getExtensionList('org.jenkinsci.plugins.configfiles.GlobalConfigFiles')[0]


println("Setting maven settings xml")


def configId =  'our_settings'
def configName = 'myMavenConfig for jenkins automation example'
def configComment = 'Global Maven Settings'
def configContent  = '''<?xml version="1.0" encoding="UTF-8"?>
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd" xmlns="http://maven.apache.org/SETTINGS/1.1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<servers>
    <server>
      <id>artifactory</id>
      <username>admin</username>
      <password>password</password>
    </server>
   </servers>
</settings>
'''

def globalConfig = new GlobalMavenSettingsConfig(configId, configName, configComment, configContent, false, null)
store.save(globalConfig)
