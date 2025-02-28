import pickle
import re
import collections
import sys


#CMDLINE ARGS
#[1] - path to data/working directory
datapath = sys.argv[1]


def load(filename):
    return pickle.load(open(filename, 'rb'))

def re_0002(i):
    # split camel case and remove special characters
    tmp = i.group(0)
    if len(tmp) > 1:
        if tmp.startswith(' '):
            return tmp
        else:
            return '{} {}'.format(tmp[0], tmp[1])
    else:
        return ' '.format(tmp)

def separate_text_struct(dat, reswords):
    textdat = list()
    structdat = list()
    for w in dat:
        if w in reswords:
            structdat.append(w)
            textdat.append('aphcmc') # placeholder token that survives filtering
        else:
            structdat.append('aphcmc')
            textdat.append(w)
    return(' '.join(textdat), ' '.join(structdat))

def camel_case_split_word(identifier):
    matches = re.finditer('.+?(?:(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|$)', identifier)
    return ' '.join([m.group(0) for m in matches])

def split_camel(tmp, reswords):
    out = list()
    for w in tmp.split(' '):
        if w in reswords:
            out.append(w)
        else:
            out.append(camel_case_split_word(w))
    return(' '.join(out))

def space_special(tmp):
    out = ''
    for w in tmp:
        if w in ['{', '}', '(', ')']:
            out += ' ' + w + ' '
        elif w in ['\n']:
            out += ' '
        else:
            out += w
    return out

def repl_ph(tmp):
    out = ''
    for w in tmp.split(' '):
        if w == 'aphcmc':
            out += ' <ph> '
        else:
            out += ' ' + w + ' '
    return out


re_0001_ = re.compile(r'([^a-zA-Z0-9 ])|([a-z0-9_][A-Z])')



#preprocess tdats
print("Removing special characters from the code")


#datatype is either tdats or smldats

def special_chars(data_type, train_type):
    outfile = workpath+data_type+"."+train_type+".pkl"
    print("Working on "+outfile)
    dats = load(outfile)
    newdats = dict()
    #c = 0
    for fid, dat in dats.items():
        #c += 1
        if fid % 100000 == 0:
            print(fid)
        newdats[fid] = re_0001_.sub(re_0002, dats[fid])
        dats = newdats
        pickle.dump(dats, open(outfile, 'wb'))


special_chars("tdats","train")
special_chars("tdats","test")
special_chars("tdats","val")
special_chars("smldats","train")
special_chars("smldats","test")
special_chars("smldats","val")



