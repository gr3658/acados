%
% Copyright 2019 Gianluca Frison, Dimitris Kouzoupis, Robin Verschueren,
% Andrea Zanelli, Niels van Duijkeren, Jonathan Frey, Tommaso Sartor,
% Branimir Novoselnik, Rien Quirynen, Rezart Qelibari, Dang Doan,
% Jonas Koenemann, Yutao Chen, Tobias Schöls, Jonas Schlagenhauf, Moritz Diehl
%
% This file is part of acados.
%
% The 2-Clause BSD License
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.;
%

function C_sim_ext_fun = sim_set_ext_fun(C_sim, C_sim_ext_fun, model_struct, opts_struct)

model_name = model_struct.name;

% get acados folder
acados_folder = getenv('ACADOS_INSTALL_DIR');
mex_flags = getenv('ACADOS_MEX_FLAGS');

% set paths
acados_mex_folder = fullfile(acados_folder, 'interfaces', 'acados_matlab_octave');
acados_include = ['-I' acados_folder];
acados_interfaces_include = ['-I' fullfile(acados_folder, 'interfaces')];
acados_lib_path = ['-L' fullfile(acados_folder, 'lib')];
acados_matlab_octave_lib_path = ['-L' fullfile(acados_folder, 'interfaces', 'acados_matlab_octave')];
model_lib_path = ['-L', opts_struct.output_dir];

%% select files to compile
ext_fun_type = model_struct.ext_fun_type; % 'casadi' or generic
mex_files = {fullfile(acados_mex_folder, ['sim_set_ext_fun_', ext_fun_type, '.c'])};
set_fields = {};
mex_fields = {};
fun_names = {};
mex_names = {};
% dynamics
if (strcmp(opts_struct.method, 'erk'))

    set_fields = {set_fields{:} ...
        'expl_ode_fun' ...
        'expl_vde_forw' ...
        'expl_vde_adj' ...
        'expl_ode_hess' ...
        };
    mex_fields = {mex_fields{:} ...
        'dyn_expl_ode_fun' ...
        'dyn_expl_vde_forw' ...
        'dyn_expl_vde_adj' ...
        'dyn_expl_ode_hess' ...
        };
    fun_names = {fun_names{:} ...
        [model_name, '_dyn_expl_ode_fun'] ...
        [model_name, '_dyn_expl_vde_forw'] ...
        [model_name, '_dyn_expl_vde_adj'] ...
        [model_name, '_dyn_expl_ode_hess'] ...
        };
    mex_names = {mex_names{:} ...
        [model_name, '_sim_set_ext_fun_dyn_expl_ode_fun'] ...
        [model_name, '_sim_set_ext_fun_dyn_expl_vde_forw'] ...
        [model_name, '_sim_set_ext_fun_dyn_expl_vde_adj'] ...
        [model_name, '_sim_set_ext_fun_dyn_expl_ode_hess'] ...
        };

elseif (strcmp(opts_struct.method, 'irk'))
    set_fields = {set_fields{:} ...
        'impl_dae_fun' ...
        'impl_dae_fun_jac_x_xdot_z' ...
        'impl_dae_jac_x_xdot_u_z' ...
        };
    mex_fields = {mex_fields{:} ...
        'dyn_impl_dae_fun' ...
        'dyn_impl_dae_fun_jac_x_xdot_z' ...
        'dyn_impl_dae_jac_x_xdot_u_z' ...
        };
    fun_names = {fun_names{:} ...
        [model_name, '_dyn_impl_dae_fun'] ...
        [model_name, '_dyn_impl_dae_fun_jac_x_xdot_z'] ...
        [model_name, '_dyn_impl_dae_jac_x_xdot_u_z'] ...
        };
    mex_names = {mex_names{:} ...
        [model_name, '_sim_set_ext_fun_dyn_impl_dae_fun'] ...
        [model_name, '_sim_set_ext_fun_dyn_impl_dae_fun_jac_x_xdot_z'] ...
        [model_name, '_sim_set_ext_fun_dyn_impl_dae_jac_x_xdot_u_z'] ...
        };
    if strcmp(opts_struct.sens_hess, 'true')
            set_fields = {set_fields{:} ...
            'impl_dae_hess' ...
            };
        mex_fields = {mex_fields{:} ...
            'dyn_impl_dae_hess' ...
            };
        fun_names = {fun_names{:} ...
            [model_name, '_dyn_impl_dae_hess'] ...
            };
        mex_names = {mex_names{:} ...
            [model_name, '_sim_set_ext_fun_dyn_impl_dae_hess'] ...
            };
    end
elseif (strcmp(opts_struct.method, 'irk_gnsf'))
    if ~model_struct.dyn_gnsf_purely_linear
        if model_struct.dyn_gnsf_nontrivial_f_LO
            set_fields = {set_fields{:} ...
                'gnsf_f_lo_fun_jac_x1k1uz' };
            mex_fields = {mex_fields{:} ...
                'dyn_gnsf_f_lo_fun_jac_x1k1uz'};
            fun_names = {fun_names{:} ...
                [model_name, '_dyn_gnsf_f_lo_fun_jac_x1k1uz'] };
            mex_names = {mex_names{:} ...
                [model_name, '_sim_set_ext_fun_dyn_gnsf_f_lo_fun_jac_x1k1uz']};
        end
        set_fields = {set_fields{:} ...
            'gnsf_phi_fun' ...
            'gnsf_phi_fun_jac_y' ...
            'gnsf_phi_jac_y_uhat' ...
            };
        mex_fields = {mex_fields{:} ...
            'dyn_gnsf_phi_fun' ...
            'dyn_gnsf_phi_fun_jac_y' ...
            'dyn_gnsf_phi_jac_y_uhat' ...
            };
        fun_names = {fun_names{:} ...
            [model_name, '_dyn_gnsf_phi_fun'] ...
            [model_name, '_dyn_gnsf_phi_fun_jac_y'] ...
            [model_name, '_dyn_gnsf_phi_jac_y_uhat'] ...
            };
        mex_names = {mex_names{:} ...
            [model_name, '_sim_set_ext_fun_dyn_gnsf_phi_fun'] ...
            [model_name, '_sim_set_ext_fun_dyn_gnsf_phi_fun_jac_y'] ...
            [model_name, '_sim_set_ext_fun_dyn_gnsf_phi_jac_y_uhat'] ...
        };
    end
    set_fields = {set_fields{:} ...
        'gnsf_get_matrices_fun' };
    mex_fields = {mex_fields{:} ...
        'dyn_gnsf_get_matrices_fun' };
    fun_names = {fun_names{:} ...
        [model_name, '_dyn_gnsf_get_matrices_fun'] };
    mex_names = {mex_names{:} ...
        [model_name, '_sim_set_ext_fun_dyn_gnsf_get_matrices_fun'] };
else
    fprintf('\nsim_set_ext_fun: method not supported: %s\n', opts_struct.method);
end


%% compile mex files
if (strcmp(opts_struct.compile_interface, 'true') || strcmp(opts_struct.codgen_model, 'true'))

    if is_octave()
        if ~exist(fullfile(opts_struct.output_dir, 'cflags_octave.txt'), 'file')
            diary(fullfile(opts_struct.output_dir, 'cflags_octave.txt'))
            diary on
            mkoctfile -p CFLAGS
            diary off
            input_file = fopen(fullfile(opts_struct.output_dir, 'cflags_octave.txt'), 'r');
            cflags_tmp = fscanf(input_file, '%[^\n]s');
            fclose(input_file);
            if ~ismac()
                cflags_tmp = [cflags_tmp, ' -std=c99 -fopenmp'];
            else
                cflags_tmp = [cflags_tmp, ' -std=c99'];
            end
            input_file = fopen(fullfile(opts_struct.output_dir, 'cflags_octave.txt'), 'w');
            fprintf(input_file, '%s', cflags_tmp);
            fclose(input_file);
        end
    %    input_file = fopen('build/cflags_octave.txt', 'r');
    %    cflags_tmp = fscanf(input_file, '%[^\n]s');
    %    fclose(input_file);
    %    setenv('CFLAGS', cflags_tmp);
    end

    %% get pointers for external functions in model
    for ii=1:length(mex_names)

        disp(['compiling ', mex_names{ii}])
        if is_octave()
    %        mkoctfile -p CFLAGS
            input_file = fopen(fullfile(opts_struct.output_dir, 'cflags_octave.txt'), 'r');
            cflags_tmp = fscanf(input_file, '%[^\n]s');
            fclose(input_file);
            cflags_tmp = [cflags_tmp, ' -DSET_FIELD=', set_fields{ii}];
            cflags_tmp = [cflags_tmp, ' -DMEX_FIELD=', mex_fields{ii}];
            cflags_tmp = [cflags_tmp, ' -DFUN_NAME=', fun_names{ii}];
            setenv('CFLAGS', cflags_tmp);
            mex(acados_include, acados_interfaces_include, acados_lib_path, acados_matlab_octave_lib_path, model_lib_path, '-lacados', '-lhpipm', '-lblasfeo', ['-l', model_name], mex_files{1});
        else
            if ~ismac()
                FLAGS = 'CFLAGS=$CFLAGS -std=c99 -fopenmp';
            else
                FLAGS = 'CFLAGS=$CFLAGS -std=c99';
            end
            mex( mex_flags, FLAGS, ['-DSET_FIELD=', set_fields{ii}],...
                 ['-DMEX_FIELD=', mex_fields{ii}], ['-DFUN_NAME=', fun_names{ii}],...
                 acados_include, acados_interfaces_include, acados_lib_path,...
                 acados_matlab_octave_lib_path, model_lib_path, '-lacados',...
                 '-lhpipm', '-lblasfeo', ['-l', model_name], mex_files{1});
        end
        
%        clear(mex_names{ii})
        movefile(['sim_set_ext_fun_', ext_fun_type, '.', mexext], fullfile(opts_struct.output_dir, [mex_names{ii}, '.', mexext]));
    end

    if is_octave()
        movefile('*.o', opts_struct.output_dir);
    end
    
end


% codegen the file to call mex files
%fileID = fopen('build/sim_set_ext_fun_tmp.m', 'w');
%fprintf(fileID, 'function C_sim_ext_fun = sim_set_ext_fun_tmp(C_sim, C_sim_ext_fun, model_struct, opts_struct)\n');
for ii=1:length(mex_names)
    C_sim_ext_fun = eval([mex_names{ii}, '(C_sim, C_sim_ext_fun, model_struct, opts_struct)']);
%    fprintf(fileID, [mex_names{ii}, '(C_sim, C_sim_ext_fun, model_struct, opts_struct);\n']);
end
%fclose(fileID);

% call mex files
%sim_set_ext_fun_tmp(C_sim, C_sim_ext_fun, model_struct, opts_struct);

return;