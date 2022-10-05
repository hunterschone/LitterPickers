function labelAndExportFig(figI,description,options)

%% preparations
if ~isfield(options,'postscriptAppendFilespec')
    options=setIfUnset(options,'postscriptOverwriteFilespec',['figure',num2str(figI)]);
end

if isempty(figI)
    figI=gcf;
end

figure(figI);
addHeading(description);


%% export
if isfield(options,'postscriptAppendFilespec')
    % append figure to postscript file specified for appending
    exportCurrentFigAsPostscript(options.postscriptAppendFilespec,1);
end

if isfield(options,'postscriptOverwriteFilespec')
    % export figure into postscript file specified for overwriting
    exportCurrentFigAsPostscript(options.postscriptOverwriteFilespec,0);
end

if isfield(options,'pdfFilespec')
    % export figure into pdf file
    % (this overwrites: appending pdfs is not possible -- except by combining pdfs)
    exportCurrentFigAsPDF_screenshot(options.postscriptFilespec);
end

