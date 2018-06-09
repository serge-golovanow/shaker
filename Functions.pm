package Functions;

################################################################################
# Functions : LIBRAIRIE de fonctions utiles
# Serge Golovanow
# Fonctions :
#   daemonize : passage en daemon (tâche de fond)
#   confcheck : vérification de l'existence du fichier de conf
#   pluriel   : renvoie un 's' si le nombre précisé en paramètre est >1
#   dec2bin   : conversion décimal -> binaire
#   bin2dec   : conversion binaire -> décimal
################################################################################

use strict;
use POSIX 'setsid';

sub daemonize {
  my ($pidfile) = @_;
  if (stat($pidfile)) {
    my $pid = `cat $pidfile`;
    $pid =~ s/\n//g;  #chomp
    if (kill(0, $pidfile)) {   #kill(0,pid) -> renvoie vrai si le process existe
      die "Process $pid is running ! Aborting...  ";
    }
    #Si le pidfile existe mais que le PID ne correspond a aucun process, on va l'ecraser ci dessous
  }

  open PIDFILE, ">$pidfile" or die "Can't open PID file $pidfile : $!  ";
  
  #chdir '/'   or die "Can't chdir to / : $!";
  open STDIN, '/dev/null' or die "Can't read /dev/null : $! ";
  open STDOUT, '>/dev/null' or die "Can't write to /dev/null : $! ";
  defined(my $pid = fork) or die "Can't fork : $! ";
  exit if $pid; # ?! ne devrait pas arrivé vu le or die ci-dessus
  setsid or die "Can't start a new session : $! ";   #necessite   use POSIX 'setsid';
  open STDERR,">&STDOUT" or die "Cant' dum stdout : $! ";
  
  print PIDFILE $$;     ## $$ -> PID courant
  close PIDFILE;
  #`echo $$ > $pidfile`;    #je crois pas que ça declenche d'erreur en cas de soucis de droits...  
  
  #Gestion des signaux
  $SIG{TERM} = sub { unlink $pidfile; exit 0; };
 
}###############################################################################

sub confcheck {
  my ($fichier) = @_;
  my $stat = stat($fichier);
  if (!$stat) { #Si le fichier de conf n'est pas dans le répertoire courant
    #my $i=0;   #Pourquoi parcourir @INC ?!
    #while (!stat($fileconf) && $i < @INC) {
    #  $fileconf = $INC[$i]."/".$ARGV[0]; 
    #  $i++;
    #}
    $0 =~ /(\.?(\/.+)+\/).*/;
    my $basedir = $1;  
    $fichier = $basedir."/".$fichier;
    if (stat($fichier)) { return $fichier; }
    else { return undef; }
  }
  else { return $fichier; }
}###############################################################################

sub pluriel {
  my ($n) = @_;
  return $n > 1 ? 's' : '';
}###############################################################################

sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}###############################################################################

sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}###############################################################################


1;