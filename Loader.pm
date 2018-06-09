package Loader;

################################################################################
# Loader - LIBRAIRIE - Rempli le tableau des jobs par des objets Job
# Serge Golovanow
# Fonctions :
#   load : charge le fichier XML en un tableau d'objets Job
#   loadJob : charge un <job> en un objet job
#   loadFile : charge un <file> en un objet File
#   loadPs : charge un <ps> en un objet Ps
################################################################################

use strict;

use XML::DOM;
#use Data::Dumper;

################################################################################
sub load {                                                             ## load #
#Fonction principale de chargement de la conf
  my ($file, $rjobs, $rconf) = @_;      # $rtoto : reference vers $toto
  my $reussite=1;
  
  if (!stat($file)) { return main::error("Error : configuration file not found"); }
  
  my $dom = new XML::DOM::Parser;                           #création d'un objet pour parser
  my $doc = $dom->parsefile($file);                             #parse
  
  #Chargement de la config du script : 
  foreach('verbose', 'delay', 'daemon', 'mailto', 'pidfile') { $$rconf{$_} = $doc->getFirstChild->getAttribute($_); }
  if (!($$rconf{'delay'})) { $$rconf{'delay'} = 300; }
  #il faudrait vérifier l'allure des adresses mails...
  foreach('verbose', 'daemon') { if ($$rconf{$_} ne $_) { $$rconf{$_} = ''; } }
  
  #Chargement des Jobs :
  my $xmljobs = $doc->getElementsByTagName ('job');          #Récupération des <job>
  my $n = $xmljobs->getLength();
  for (my $i = 0; $i < $n; $i++) {                       #Boucle sur les <job>
    my $ojob = loadJob($xmljobs->item($i));         #traitement du <job>
    if ($ojob) { push (@$rjobs,$ojob); }           #ajout au tableau @jobs principal
    else { $reussite=0; }
    #sleep 1;
  }
  return $reussite;
}###############################################################################

################################################################################
sub loadJob {                                                       ## loadJob #
#Traitement d'un <job> : renvoie un objet Job
  my ($xmljob) = @_;
  my $ojob = Job->new($xmljob->getAttribute('name'));
  my $n;
  my $xmlelements;
  
  #Traitement des <ps> : 
  $xmlelements = $xmljob->getElementsByTagName('ps');
  $n = $xmlelements->getLength();
  for (my $i = 0; $i < $n; $i++) {
    my $obj = loadPs($xmlelements->item($i));
    $ojob->addChecking($obj) if $obj;
  }
  
  #Traitement des <file> :
  $xmlelements = $xmljob->getElementsByTagName('file');
  $n = $xmlelements->getLength();
  for (my $i = 0; $i < $n; $i++) {
    my $file = loadFile($xmlelements->item($i)); #File->new($xmlelement->getAttribute('file'));
    $ojob->addChecking($file) if $file; 
  }  
  
  return $ojob;
}###############################################################################

################################################################################
sub loadFile {                                                     ## loadFile #
#Traitement d'un <file> : renvoie un objet File
  my ($xml) = @_;
  return undef if !$xml;
  my $fsfile = ($xml->getFirstChild);
  my $fsfile = $fsfile->toString if $fsfile;
  return undef if !$fsfile;
  my $mtime = $xml->getAttribute('mtime');
  my $objet = File->new($fsfile);
  $objet->setMtime($mtime) if ($mtime && $objet);
  return $objet;
}###############################################################################

################################################################################
sub loadPs {                                                         ## loadPS #
#Traitement d'un <ps> : renvoie un objet Ps, undef si erreur
  my ($xmlchecking) = @_;         #Récuperation de l'objet XML du <checking action="ps">
  my $ops = Ps->new();      #Création de l'objet Ps
  
  #Traitement des <grep>
  my $xmlgreps = $xmlchecking->getElementsByTagName('grep');
  my $n = $xmlgreps->getLength();
  return undef if !$n;             #s'il n'y a pas de <grep>, erreur
  
  for (my $i=0;$i<$n; $i++) {   #boucle sur les <grep>
    $ops->addGrep($xmlgreps->item($i)->getFirstChild->toString);
  }
  
  #Traitement des <base>
  my $xmlbases = $xmlchecking->getElementsByTagName('base');
  $n = $xmlbases->getLength();
  for (my $i=0;$i<$n; $i++) {     #bouche sur les <base>
    $ops->addBase($xmlbases->item($i)->getFirstChild->toString);
  }  
  
  #traitement de min="", max=""
  my $min = $xmlchecking->getAttribute('min');
  $ops->setMin($min) if $min; # ? $min : undef);
  my $max = $xmlchecking->getAttribute('max');
  $ops->setMax($max) if $max; # ? $max : undef);
  
  return $ops;            #Renvoi de l'objet Ps
}###############################################################################

1;
