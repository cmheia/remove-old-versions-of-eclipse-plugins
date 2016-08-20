#!/bin/bash
# scan_old_plugins.sh

# script to scan for duplicate old eclipse features, plugins and dropins
# generates a "clean_old_plugins.sh" script to clean old versions.
# warning: DANGEROUS! review clean_old_plugins.sh script before running it.

LogDir=$(date +%Y%m%d%H%M%S)
LogFileName="${LogDir}.log"

TargetDirs=(dropins features plugins)
BackupDir=Backups-${LogDir}

BundlesInfoTargetDirs=(plugins)
BundlesInfo="../configuration/org.eclipse.equinox.simpleconfigurator/bundles.info"
ParseBundlesInfo=y

DropinsDir=dropins
FeaturesDir=features
PluginsDir=plugins

CanonicalPluginsFile=canonical_plugins.txt
RegisteredPluginsFile=registered_plugins.txt
CleanPluginScriptFile=clean_old_plugins.sh

ByBundlesInfoFilePrefix=by_bundles_info-

IsDirAlreadyExist=$(mkdir ${LogDir} 2>&1)

if [ "Be${IsDirAlreadyExist}Careful" != "BeCareful" ]; then
	echo "mkdir raise error > ${IsDirAlreadyExist}"
	exit -1
else
	echo "logs available at ${LogDir}"
fi

cd ${LogDir}

# http://linux.die.net/abs-guide/here-docs.html
cat > ${CleanPluginScriptFile} <<End-of-message
#!/bin/bash
# ${CleanPluginScriptFile}

# script to scan for duplicate old eclipse features, plugins and dropins
# generates a "${CleanPluginScriptFile}" script to clean old versions.
# warning: DANGEROUS! review ${CleanPluginScriptFile} script before running it.

End-of-message

# (
# cat <<End-of-message
# #!/bin/bash
# # ${CleanPluginScriptFile}

# # script to scan for duplicate old eclipse features, plugins and dropins
# # generates a "${CleanPluginScriptFile}" script to clean old versions.
# # warning: DANGEROUS! review ${CleanPluginScriptFile} script before running it.

# End-of-message
# ) > ${CleanPluginScriptFile}

if [ -e "${BundlesInfo}" ] ; then
	echo "bundles.info available..."
	ParseBundlesInfo=y
else
	echo "bundles.info not found..."
	ParseBundlesInfo=n
fi

(
for dir in ${TargetDirs[@]}
do
	echo "" > ${dir}-${CanonicalPluginsFile}
	echo "" > ${dir}-${RegisteredPluginsFile}

	echo "Processing [${dir}] directory..."
	echo "Processing [${dir}] directory..." 1>&2

	FileList=$(ls "../${dir}" | sort -r);
	echo "${FileList}" > ${dir}-all.txt

	for p in $(echo "${FileList}")
	do
		v=$(echo ${p} | sed -e 's/_[0-9\._\-]*/_[0-9\\._\\-]*/g' -e 's/\([^\\]\)\./\1\\./g' -e 's/[^a-zA-Z]\{1,\}[0-9]\{2,\}/[0-9]*/g')
		g=$(grep -l "${v}" ${dir}-${RegisteredPluginsFile} | head -1 | awk '{print $1}')
		if [ "Is${g}Empty" = "IsEmpty" ]; then
			echo "[fresh]${p} > ${v}"
			echo "${p}" >> ${dir}-${RegisteredPluginsFile}
			echo "${v}=${p}" >> ${dir}-${CanonicalPluginsFile}
		else
			echo "[stale]${p} > ${v}"
			echo "mv ${dir}/${p} ${BackupDir}/${dir}/" >> ${dir}-${CleanPluginScriptFile}
		fi
	done

	if [ -e "${dir}-${CleanPluginScriptFile}" ] ; then
		echo -e "echo \"Processing [${dir}] directory...\"" >> ${CleanPluginScriptFile}

cat >> ${CleanPluginScriptFile} <<End-of-message
if [ ! -d "${BackupDir}/${dir}" ] ; then
	echo "creat dir ${BackupDir}/${dir}"
	mkdir -p "${BackupDir}/${dir}"
fi

End-of-message

		cat ${dir}-${CleanPluginScriptFile} >> ${CleanPluginScriptFile}
	else
		echo "nothing to do with [${dir}] directory, it's clean"
		echo "nothing to do with [${dir}] directory, it's clean" 1>&2
		echo -e "echo \"nothing to do with [${dir}] directory, it's clean\"" >> ${CleanPluginScriptFile}
	fi
done
) > by_compare-${LogFileName}


if [ "${ParseBundlesInfo}" = "y" ]; then
cat > ${ByBundlesInfoFilePrefix}${CleanPluginScriptFile} <<End-of-message
#!/bin/bash
# ${ByBundlesInfoFilePrefix}${CleanPluginScriptFile}

# script to scan for duplicate old eclipse features, plugins and dropins by parseing bundles.info.
# generates a "${ByBundlesInfoFilePrefix}${CleanPluginScriptFile}" script to clean old versions.
# warning: DANGEROUS! review ${ByBundlesInfoFilePrefix}${CleanPluginScriptFile} script before running it.

End-of-message

	(
	echo "Parseing bundles.info..."
	echo -e "\nParseing bundles.info..." 1>&2
	for dir in ${BundlesInfoTargetDirs[@]}
	do
		echo "" > ${ByBundlesInfoFilePrefix}${dir}-${CanonicalPluginsFile}
		echo "" > ${ByBundlesInfoFilePrefix}${dir}-${RegisteredPluginsFile}

		echo "Processing [${dir}] directory..."
		echo "Processing [${dir}] directory..." 1>&2

		FileList=$(cat ${dir}-all.txt);

		for p in $(echo "${FileList}")
		do
			g=$(grep -l "${p}" ${BundlesInfo} | head -1 | awk '{print $1}')
			if [ "Not${g}Registered" = "NotRegistered" ]; then
				echo "[stale]${p}"
				echo "mv ${dir}/${p} ${ByBundlesInfoFilePrefix}${BackupDir}/${dir}/" >> ${ByBundlesInfoFilePrefix}${dir}-${CleanPluginScriptFile}
			else
				echo "[fresh]${p}"
				echo "${p}" >> ${ByBundlesInfoFilePrefix}${dir}-${RegisteredPluginsFile}
			fi
		done
		if [ -e "${ByBundlesInfoFilePrefix}${dir}-${CleanPluginScriptFile}" ] ; then
			echo -e "echo \"Processing [${dir}] directory...\"" >> ${ByBundlesInfoFilePrefix}${CleanPluginScriptFile}

cat >> ${ByBundlesInfoFilePrefix}${CleanPluginScriptFile} <<End-of-message
if [ ! -d "${ByBundlesInfoFilePrefix}${BackupDir}/${dir}" ] ; then
	echo "creat dir ${ByBundlesInfoFilePrefix}${BackupDir}/${dir}"
	mkdir -p "${ByBundlesInfoFilePrefix}${BackupDir}/${dir}"
fi

End-of-message

			cat ${ByBundlesInfoFilePrefix}${dir}-${CleanPluginScriptFile} >> ${ByBundlesInfoFilePrefix}${CleanPluginScriptFile}
		else
			echo "nothing to do with [${dir}] directory, it's clean"
			echo "nothing to do with [${dir}] directory, it's clean" 1>&2
			echo -e "echo \"nothing to do with [${dir}] directory, it's clean\"" >> ${ByBundlesInfoFilePrefix}${CleanPluginScriptFile}
		fi
	done
	) > ${ByBundlesInfoFilePrefix}${LogFileName}
fi
