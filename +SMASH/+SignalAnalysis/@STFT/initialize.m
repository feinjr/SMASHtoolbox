function object=initialize(object)

object.Name='STFT object';
set(object.GraphicOptions,'Title','STFT object');
object.FFToptions=SMASH.General.FFToptions;

end